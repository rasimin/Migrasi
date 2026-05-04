using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Migrasi
{
    public partial class DatabaseSearch : Page
    {
        protected global::System.Web.UI.WebControls.DropDownList ddlDatabase;
        protected global::System.Web.UI.WebControls.TextBox txtSearch;
        protected global::System.Web.UI.WebControls.LinkButton btnSearch;
        protected global::System.Web.UI.WebControls.GridView gvResults;

        string connString = ConfigurationManager.ConnectionStrings["SimulasiDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDatabases();
            }
        }

        private void LoadDatabases()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT name FROM sys.databases WHERE state_desc = 'ONLINE' ORDER BY name";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            ddlDatabase.DataSource = reader;
                            ddlDatabase.DataTextField = "name";
                            ddlDatabase.DataValueField = "name";
                            ddlDatabase.DataBind();
                        }
                    }
                    string defaultDb = conn.Database;
                    if (ddlDatabase.Items.FindByValue(defaultDb) != null)
                    {
                        ddlDatabase.SelectedValue = defaultDb;
                    }
                }
            }
            catch
            {
                try
                {
                    SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connString);
                    string defaultDb = builder.InitialCatalog;
                    ddlDatabase.Items.Clear();
                    if (!string.IsNullOrEmpty(defaultDb))
                    {
                        ddlDatabase.Items.Add(new ListItem(defaultDb, defaultDb));
                        ddlDatabase.SelectedValue = defaultDb;
                    }
                }
                catch { }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string term = txtSearch.Text.Trim();
            if (string.IsNullOrEmpty(term)) return;

            BindResults(term);
        }

        private void BindResults(string term)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    // Ganti fokus database sesuai pilihan
                    string selectedDb = ddlDatabase.SelectedValue;
                    conn.Open();
                    if (!string.IsNullOrEmpty(selectedDb) && !selectedDb.Equals(conn.Database, StringComparison.OrdinalIgnoreCase))
                    {
                        conn.ChangeDatabase(selectedDb);
                    }

                    // Check if procedure exists in the selected database
                    EnsureProcedureExists(conn);
 
                     using (SqlCommand cmd = new SqlCommand("_FindTableOrSP", conn))
                     {
                         cmd.CommandType = CommandType.StoredProcedure;
                         cmd.Parameters.AddWithValue("@TableOrSPName", term);

                        SqlDataAdapter sda = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        gvResults.DataSource = dt;
                        gvResults.DataBind();
                    }
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"showAlert('Error', '{ex.Message.Replace("'", "")}', 'error');", true);
                }
            }
        }

        private void EnsureProcedureExists(SqlConnection conn)
        {
            string checkSql = "SELECT COUNT(*) FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_FindTableOrSP]') AND type in (N'P', N'PC')";
            if (conn.State != ConnectionState.Open) conn.Open();
            
            using (SqlCommand cmd = new SqlCommand(checkSql, conn))
            {
                int exists = (int)cmd.ExecuteScalar();
                if (exists == 0)
                {
                    string createSql = @"
                        CREATE PROCEDURE [dbo].[_FindTableOrSP]
	                        @TableOrSPName VARCHAR(100)
                        AS
                        BEGIN
	                        SET NOCOUNT ON;
	                        SELECT DISTINCT o.name, o.xtype
	                        FROM syscomments c
	                        INNER JOIN sysobjects o ON c.id=o.id
	                        WHERE c.text LIKE '%' + @TableOrSPName + '%'
                            ORDER BY o.name
                        END";
                    using (SqlCommand createCmd = new SqlCommand(createSql, conn))
                    {
                        createCmd.ExecuteNonQuery();
                    }
                }
            }
        }

        protected void gvResults_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetail")
            {
                string objectName = e.CommandArgument.ToString();
                string script = GetObjectScript(objectName);
                
                byte[] scriptBytes = System.Text.Encoding.UTF8.GetBytes(script);
                string base64Script = Convert.ToBase64String(scriptBytes);
                ScriptManager.RegisterStartupScript(this, GetType(), "showDetail", $"showScriptModal('{objectName}', '{base64Script}');", true);
            }
        }

        private string GetObjectScript(string objectName)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    string selectedDb = ddlDatabase.SelectedValue;
                    conn.Open();
                    if (!string.IsNullOrEmpty(selectedDb) && !selectedDb.Equals(conn.Database, StringComparison.OrdinalIgnoreCase))
                    {
                        conn.ChangeDatabase(selectedDb);
                    }

                    // Using sys.sql_modules for complete script retrieval
                    string sql = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID(@Name)";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Name", objectName);
                        object result = cmd.ExecuteScalar();
                        
                        if (result != null && result != DBNull.Value)
                        {
                            return result.ToString();
                        }
                        
                        // Fallback to sp_helptext if not in modules (e.g. some system objects or old tables)
                        conn.Close();
                        conn.Open();
                        using (SqlCommand helpCmd = new SqlCommand("sp_helptext", conn))
                        {
                            helpCmd.CommandType = CommandType.StoredProcedure;
                            helpCmd.Parameters.AddWithValue("@objname", objectName);
                            
                            using (SqlDataReader reader = helpCmd.ExecuteReader())
                            {
                                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                                while (reader.Read())
                                {
                                    sb.Append(reader[0].ToString());
                                }
                                return sb.ToString();
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    return "-- Error retrieving script: " + ex.Message;
                }
            }
        }

        protected string GetTypeName(string xtype)
        {
            switch (xtype.Trim().ToUpper())
            {
                case "P": return "Stored Procedure";
                case "U": return "User Table";
                case "V": return "View";
                case "FN": return "Scalar Function";
                case "TF": return "Table Function";
                case "TR": return "Trigger";
                default: return xtype;
            }
        }

        protected string GetBadgeClass(string xtype)
        {
            switch (xtype.Trim().ToUpper())
            {
                case "P": return "badge bg-info text-dark shadow-sm px-3 py-2";
                case "U": return "badge bg-primary text-white shadow-sm px-3 py-2";
                case "V": return "badge bg-success text-white shadow-sm px-3 py-2";
                default: return "badge bg-secondary text-white shadow-sm px-3 py-2";
            }
        }
    }
}
