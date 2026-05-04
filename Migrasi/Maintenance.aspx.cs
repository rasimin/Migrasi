using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Migrasi
{
    public partial class Maintenance : Page
    {
            string connString = ConnectionHelper.GetActiveConnectionString();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDatabases();
                BindGrid();
            }
        }

        private void LoadDatabases()
        {
            ddlTargetDB.Items.Clear();
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
                            ddlTargetDB.DataSource = reader;
                            ddlTargetDB.DataTextField = "name";
                            ddlTargetDB.DataValueField = "name";
                            ddlTargetDB.DataBind();
                        }
                    }
                }
            }
            catch
            {
                try
                {
                    SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connString);
                    string defaultDb = builder.InitialCatalog;
                    if (!string.IsNullOrEmpty(defaultDb))
                    {
                        ddlTargetDB.Items.Add(new ListItem(defaultDb, defaultDb));
                    }
                }
                catch { }
            }
            
            // Tambahkan opsi default kosong
            ddlTargetDB.Items.Insert(0, new ListItem("-- Default (Connection String) --", ""));
        }

        private void BindGrid()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT * FROM T_MaintenanceGenerate";
                    // Cek apakah kolom CreatedAt ada sebelum melakukan sorting
                    using (SqlCommand checkCmd = new SqlCommand("IF COL_LENGTH('T_MaintenanceGenerate', 'CreatedAt') IS NOT NULL SELECT 1 ELSE SELECT 0", conn))
                    {
                        conn.Open();
                        bool hasCreatedAt = (int)checkCmd.ExecuteScalar() == 1;
                        if (hasCreatedAt) query += " ORDER BY CreatedAt DESC";
                    }
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);

                            // Tambahkan kolom CreatedAt bayangan jika belum ada di database
                            // agar GridView tidak error saat binding.
                            if (!dt.Columns.Contains("CreatedAt"))
                            {
                                dt.Columns.Add("CreatedAt", typeof(DateTime));
                            }

                            gvMaintenance.DataSource = dt;
                            gvMaintenance.DataBind();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("T_MaintenanceGenerate"))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showAlert('Setup Required', 'Table T_MaintenanceGenerate is missing. Please run the SQL Setup script first.', 'warning');", true);
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int id = int.Parse(hfID.Value);
            string fileName = txtFileName.Text.Trim();
            string generateType = ddlGenerateType.SelectedValue;
            string spName = txtSPName.Text.Trim();
            string spUpload = txtSPUpload.Text.Trim();
            string targetDb = ddlTargetDB.SelectedValue;

            if (string.IsNullOrEmpty(fileName) || string.IsNullOrEmpty(spName))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showAlert('Wait', 'Please fill all fields', 'warning');", true);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // Validation: Check for duplicate File Name
                string checkQuery = "SELECT COUNT(*) FROM T_MaintenanceGenerate WHERE FileGenerate = @File AND ID <> @ID";
                using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                {
                    checkCmd.Parameters.AddWithValue("@File", fileName);
                    checkCmd.Parameters.AddWithValue("@ID", id);
                    int count = (int)checkCmd.ExecuteScalar();

                    if (count > 0)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showAlert('Duplicate!', 'Configuration for file name \"' + fileName + '\" already exists. Please use a unique name.', 'error');", true);
                        return;
                    }
                }

                string query = "";
                if (id == 0)
                    query = "INSERT INTO T_MaintenanceGenerate (FileGenerate, GenerateType, NamaSPGenerate, NamaSPUpload, TargetDB) VALUES (@File, @Type, @SP, @SPUp, @TargetDB)";
                else
                    query = "UPDATE T_MaintenanceGenerate SET FileGenerate = @File, GenerateType = @Type, NamaSPGenerate = @SP, NamaSPUpload = @SPUp, TargetDB = @TargetDB WHERE ID = @ID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@File", fileName);
                    cmd.Parameters.AddWithValue("@Type", generateType);
                    cmd.Parameters.AddWithValue("@SP", spName);
                    cmd.Parameters.AddWithValue("@SPUp", (object)spUpload ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@TargetDB", string.IsNullOrEmpty(targetDb) ? DBNull.Value : (object)targetDb);
                    
                    if (id != 0) cmd.Parameters.AddWithValue("@ID", id);

                    cmd.ExecuteNonQuery();
                }
            }

            ResetForm();
            BindGrid();
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showAlert('Success', 'Data saved successfully', 'success');", true);
        }

        protected void gvMaintenance_RowEditing(object sender, GridViewEditEventArgs e)
        {
            int id = Convert.ToInt32(gvMaintenance.DataKeys[e.NewEditIndex].Value);
            LoadDataToForm(id);
            e.Cancel = true; // Prevent default editing mode
            ScriptManager.RegisterStartupScript(this, GetType(), "showModal", "showModal();", true);
        }

        private void LoadDataToForm(int id)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT * FROM T_MaintenanceGenerate WHERE ID = @ID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            hfID.Value = dr["ID"].ToString();
                            txtFileName.Text = dr["FileGenerate"].ToString();
                            
                            string genType = dr["GenerateType"] != DBNull.Value ? dr["GenerateType"].ToString() : "SP";
                            if (ddlGenerateType.Items.FindByValue(genType) != null)
                            {
                                ddlGenerateType.SelectedValue = genType;
                            }
                            
                            txtSPName.Text = dr["NamaSPGenerate"].ToString();
                            txtSPUpload.Text = dr["NamaSPUpload"].ToString();
                            
                            string targetDb = dr["TargetDB"] != DBNull.Value ? dr["TargetDB"].ToString() : "";
                            if (ddlTargetDB.Items.FindByValue(targetDb) != null)
                            {
                                ddlTargetDB.SelectedValue = targetDb;
                            }
                            else
                            {
                                ddlTargetDB.SelectedIndex = 0;
                            }
                        }
                    }
                }
            }
        }

        protected void gvMaintenance_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvMaintenance.DataKeys[e.RowIndex].Value);
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "DELETE FROM T_MaintenanceGenerate WHERE ID = @ID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    conn.Close();
                }
            }
            BindGrid();
        }

        private void ResetForm()
        {
            hfID.Value = "0";
            txtFileName.Text = "";
            ddlGenerateType.SelectedValue = "SP";
            txtSPName.Text = "";
            txtSPUpload.Text = "";
            ddlTargetDB.SelectedIndex = 0;
        }
        [System.Web.Services.WebMethod]
        public static bool ExecuteSPScript(string script, string targetDb)
        {
                string connString = ConnectionHelper.GetActiveConnectionString();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();
                    if (!string.IsNullOrEmpty(targetDb)) conn.ChangeDatabase(targetDb);
                    
                    using (SqlCommand cmd = new SqlCommand(script, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                    return true;
                }
                catch (Exception)
                {
                    return false;
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static object CreateSPFromColumns(string spName, string targetDb, string columns)
        {
                string connString = ConnectionHelper.GetActiveConnectionString();
            try
            {
                string[] cols = columns.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (cols.Length == 0)
                    return new { success = false, message = "No columns provided." };

                // Build CREATE PROCEDURE script server-side
                string sql = "CREATE PROCEDURE [dbo].[" + spName + "]\n";
                for (int i = 0; i < cols.Length; i++)
                {
                    string paramName = cols[i].Trim().Replace(" ", "_");
                    string comma = (i == cols.Length - 1) ? "" : ",";
                    sql += "    @" + paramName + " VARCHAR(MAX)" + comma + "\n";
                }
                sql += "AS\nBEGIN\n    SET NOCOUNT ON;\n    -- Auto-generated by Ingestion System\nEND";

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    if (!string.IsNullOrEmpty(targetDb)) conn.ChangeDatabase(targetDb);

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
                return new { success = true, message = "Stored Procedure [" + spName + "] created successfully!", script = sql };
            }
            catch (Exception ex)
            {
                return new { success = false, message = ex.Message };
            }
        }

        [System.Web.Services.WebMethod]
        public static object CreateSPAndUpdateConfig(string spName, string targetDb, string columns, int configId)
        {
                string connString = ConnectionHelper.GetActiveConnectionString();
            try
            {
                string[] cols = columns.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (cols.Length == 0)
                    return new { success = false, message = "No columns provided." };

                // Build CREATE PROCEDURE script
                string sql = "CREATE PROCEDURE [dbo].[" + spName + "]\n";
                for (int i = 0; i < cols.Length; i++)
                {
                    string paramName = cols[i].Trim().Replace(" ", "_");
                    string comma = (i == cols.Length - 1) ? "" : ",";
                    sql += "    @" + paramName + " VARCHAR(MAX)" + comma + "\n";
                }
                sql += "AS\nBEGIN\n    SET NOCOUNT ON;\n    -- Auto-generated by Ingestion System\nEND";

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    // Execute CREATE SP in target DB
                    if (!string.IsNullOrEmpty(targetDb))
                    {
                        conn.ChangeDatabase(targetDb);
                    }
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // Switch back to main DB to update config
                    SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connString);
                    conn.ChangeDatabase(builder.InitialCatalog);

                    // Update NamaSPUpload in config
                    string updateSql = "UPDATE T_MaintenanceGenerate SET NamaSPUpload = @SP WHERE ID = @ID";
                    using (SqlCommand uCmd = new SqlCommand(updateSql, conn))
                    {
                        uCmd.Parameters.AddWithValue("@SP", spName);
                        uCmd.Parameters.AddWithValue("@ID", configId);
                        uCmd.ExecuteNonQuery();
                    }
                }
                return new { success = true, message = "SP [" + spName + "] created & config updated!" };
            }
            catch (Exception ex)
            {
                return new { success = false, message = ex.Message };
            }
        }

        [System.Web.Services.WebMethod]
        public static bool CheckSPExists(string spName, string targetDb)
        {
                string connString = ConnectionHelper.GetActiveConnectionString();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();
                    if (!string.IsNullOrEmpty(targetDb) && targetDb != "(Default DB)") conn.ChangeDatabase(targetDb);
                    
                    string sql = "SELECT COUNT(*) FROM sys.objects WHERE object_id = OBJECT_ID(@SPName) AND type = 'P'";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@SPName", spName);
                        return (int)cmd.ExecuteScalar() > 0;
                    }
                }
                catch { return false; }
            }
        }

        [System.Web.Services.WebMethod]
        public static List<ParameterInfo> GetSPParameters(string spName, string targetDb, int configId)
        {
            List<ParameterInfo> list = new List<ParameterInfo>();
            if (string.IsNullOrEmpty(spName)) return list;

                string connString = ConnectionHelper.GetActiveConnectionString();

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    
                    // 1. Get existing mappings (from the MAIN database)
                    Dictionary<string, string> existingMappings = new Dictionary<string, string>();
                    string mapQuery = "SELECT SourceColumn, TargetParameter FROM T_MappingDetail WHERE ConfigID = @CID";
                    using (SqlCommand mCmd = new SqlCommand(mapQuery, conn))
                    {
                        mCmd.Parameters.AddWithValue("@CID", configId);
                        using (SqlDataReader mReader = mCmd.ExecuteReader())
                        {
                            while (mReader.Read())
                            {
                                existingMappings[mReader["TargetParameter"].ToString()] = mReader["SourceColumn"].ToString();
                            }
                        }
                    }

                    // 2. Switch to Target DB if specified
                    if (!string.IsNullOrEmpty(targetDb) && targetDb != "(Default DB)")
                    {
                        conn.ChangeDatabase(targetDb);
                    }

                    // 3. Check if SP Exists in the CURRENT (possibly switched) database
                    string checkSql = "SELECT COUNT(*) FROM sys.objects WHERE object_id = OBJECT_ID(@SPName) AND type = 'P'";
                    using (SqlCommand cCmd = new SqlCommand(checkSql, conn))
                    {
                        cCmd.Parameters.AddWithValue("@SPName", spName);
                        int spExists = (int)cCmd.ExecuteScalar();
                        if (spExists == 0) return list; // Return empty list to show 'Generate' UI
                    }

                    // 4. Get SP Parameters
                    string sql = @"
                        SELECT 
                            p.name AS ParamName,
                            t.name AS DataType,
                            p.max_length,
                            p.is_output
                        FROM sys.parameters p
                        INNER JOIN sys.types t ON p.user_type_id = t.user_type_id
                        WHERE p.object_id = OBJECT_ID(@SPName)";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@SPName", spName);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string pName = reader["ParamName"].ToString();
                                list.Add(new ParameterInfo
                                {
                                    ParamName = pName,
                                    DataType = reader["DataType"].ToString().ToUpper(),
                                    IsRequired = true,
                                    MappedColumn = existingMappings.ContainsKey(pName) ? existingMappings[pName] : null
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
                // On any error (connection, etc), return empty list so the UI can at least suggest generating
                return list;
            }
            return list;
        }

        [System.Web.Services.WebMethod]
        public static bool SaveMapping(int configId, List<MappingEntry> mappings)
        {
                string connString = ConnectionHelper.GetActiveConnectionString();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlTransaction trans = conn.BeginTransaction();
                try
                {
                    // Delete old mapping
                    string delSql = "DELETE FROM T_MappingDetail WHERE ConfigID = @CID";
                    using (SqlCommand dCmd = new SqlCommand(delSql, conn, trans))
                    {
                        dCmd.Parameters.AddWithValue("@CID", configId);
                        dCmd.ExecuteNonQuery();
                    }

                    // Insert new mapping
                    string insSql = "INSERT INTO T_MappingDetail (ConfigID, SourceColumn, TargetParameter) VALUES (@CID, @SC, @TP)";
                    foreach (var m in mappings)
                    {
                        using (SqlCommand iCmd = new SqlCommand(insSql, conn, trans))
                        {
                            iCmd.Parameters.AddWithValue("@CID", configId);
                            iCmd.Parameters.AddWithValue("@SC", m.SourceColumn);
                            iCmd.Parameters.AddWithValue("@TP", m.TargetParameter);
                            iCmd.ExecuteNonQuery();
                        }
                    }
                    trans.Commit();
                    return true;
                }
                catch
                {
                    trans.Rollback();
                    return false;
                }
            }
        }

        public class ParameterInfo
        {
            public string ParamName { get; set; }
            public string DataType { get; set; }
            public bool IsRequired { get; set; }
            public string MappedColumn { get; set; }
        }

        public class MappingEntry
        {
            public string SourceColumn { get; set; }
            public string TargetParameter { get; set; }
        }
        [System.Web.Services.WebMethod]
        public static object QuickGenerateSP(string query, string targetDb, string spName)
        {
                string connString = ConnectionHelper.GetActiveConnectionString();
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    if (!string.IsNullOrEmpty(targetDb) && targetDb != "(Default DB)") conn.ChangeDatabase(targetDb);

                    // Use SET FMTONLY ON to get schema without executing data
                    string schemaQuery = "SET FMTONLY ON; " + query + "; SET FMTONLY OFF;";
                    using (SqlCommand cmd = new SqlCommand(schemaQuery, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SchemaOnly))
                        {
                            DataTable schema = reader.GetSchemaTable();
                            if (schema == null) return new { success = false, message = "Could not retrieve schema from query." };

                            string script = "/****** Object:  StoredProcedure [dbo].[" + spName + "] ******/\n";
                            script += "CREATE PROCEDURE [dbo].[" + spName + "]\n";
                            
                            List<string> paramList = new List<string>();
                            foreach (DataRow row in schema.Rows)
                            {
                                string colName = row["ColumnName"].ToString();
                                string dbType = row["DataTypeName"].ToString().ToLower();
                                string spType = GuessSQLType(dbType);
                                paramList.Add("    @" + colName.Replace(" ", "_") + " " + spType);
                            }

                            script += string.Join(",\n", paramList);
                            script += "\nAS\nBEGIN\n    SET NOCOUNT ON;\n\n    -- TODO: Implement your upload logic here\n    -- Example: INSERT INTO YourTable (...) VALUES (...) \n\nEND";

                            return new { success = true, script = script };
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return new { success = false, message = "Schema Error: " + ex.Message };
            }
        }

        private static string GuessSQLType(string dbType)
        {
            if (dbType.Contains("int")) return "INT";
            if (dbType.Contains("decimal") || dbType.Contains("numeric") || dbType.Contains("money") || dbType.Contains("float") || dbType.Contains("real")) 
                return "DECIMAL(18, 4)";
            if (dbType.Contains("date") || dbType.Contains("time")) return "DATETIME";
            return "VARCHAR(500)";
        }

        [System.Web.Services.WebMethod]
        public static object ExecuteAndSyncSP(string script, string spName, string targetDb, int configId, bool downloadOnly)
        {
                string connString = ConnectionHelper.GetActiveConnectionString();
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    // 1. Create SP in target DB (Only if NOT downloadOnly)
                    if (!downloadOnly)
                    {
                        if (!string.IsNullOrEmpty(targetDb) && targetDb != "(Default DB)") conn.ChangeDatabase(targetDb);

                        using (SqlCommand cmd = new SqlCommand(script, conn))
                        {
                            cmd.ExecuteNonQuery();
                        }
                    }

                    // 2. Sync back to Maintenance Table (Config DB)
                    SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connString);
                    conn.ChangeDatabase(builder.InitialCatalog);

                    string updateSql = "UPDATE T_MaintenanceGenerate SET NamaSPUpload = @SP WHERE ID = @ID";
                    using (SqlCommand uCmd = new SqlCommand(updateSql, conn))
                    {
                        uCmd.Parameters.AddWithValue("@SP", spName);
                        uCmd.Parameters.AddWithValue("@ID", configId);
                        uCmd.ExecuteNonQuery();
                    }

                    return new { success = true };
                }
            }
            catch (Exception ex)
            {
                return new { success = false, message = "Execution Error: " + ex.Message };
            }
        }
    }
}
