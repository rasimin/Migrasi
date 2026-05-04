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
    public partial class Logs : Page
    {
        string connString = ConnectionHelper.GetActiveConnectionString();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private void BindGrid()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    List<string> conditions = new List<string>();
                    
                    string statusFilter = ddlStatusFilter.SelectedValue;
                    if (!string.IsNullOrEmpty(statusFilter)) conditions.Add("Status = @Status");

                    if (!string.IsNullOrEmpty(txtStartDate.Text)) conditions.Add("CreatedAt >= @Start");
                    if (!string.IsNullOrEmpty(txtEndDate.Text)) conditions.Add("CreatedAt <= @End");

                    string search = txtSearch.Text.Trim();
                    if (!string.IsNullOrEmpty(search))
                    {
                        conditions.Add("(FileName LIKE @Search OR ScriptExecuted LIKE @Search OR RawData LIKE @Search)");
                    }

                    string query = "SELECT * FROM T_UploadLog";
                    if (conditions.Count > 0)
                    {
                        query += " WHERE " + string.Join(" AND ", conditions);
                    }
                    
                    // Cek apakah kolom CreatedAt ada sebelum melakukan sorting
                    using (SqlCommand checkCmd = new SqlCommand("IF COL_LENGTH('T_UploadLog', 'CreatedAt') IS NOT NULL SELECT 1 ELSE SELECT 0", conn))
                    {
                        conn.Open();
                        bool hasCreatedAt = (int)checkCmd.ExecuteScalar() == 1;
                        if (hasCreatedAt) query += " ORDER BY CreatedAt DESC";
                    }

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        if (!string.IsNullOrEmpty(statusFilter)) cmd.Parameters.AddWithValue("@Status", statusFilter);
                        
                        if (!string.IsNullOrEmpty(txtStartDate.Text)) 
                            cmd.Parameters.AddWithValue("@Start", txtStartDate.Text);
                        
                        if (!string.IsNullOrEmpty(txtEndDate.Text)) 
                            cmd.Parameters.AddWithValue("@End", txtEndDate.Text + " 23:59:59");

                        if (!string.IsNullOrEmpty(search)) 
                            cmd.Parameters.AddWithValue("@Search", "%" + search + "%");

                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);

                            if (!dt.Columns.Contains("CreatedAt"))
                            {
                                dt.Columns.Add("CreatedAt", typeof(DateTime));
                            }

                            gvLogs.DataSource = dt;
                            gvLogs.DataBind();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("T_UploadLog"))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showAlert('Setup Required', 'Table T_UploadLog is missing. Please run the SQL Setup script on the Logs page.', 'warning');", true);
                }
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            gvLogs.PageIndex = 0;
            BindGrid();
        }

        protected void gvLogs_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLogs.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void btnClearLogs_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "TRUNCATE TABLE T_UploadLog";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            BindGrid();
        }
    }
}
