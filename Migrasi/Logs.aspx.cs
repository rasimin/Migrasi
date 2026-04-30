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
        string connString = ConfigurationManager.ConnectionStrings["SimulasiDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private void BindGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT * FROM T_UploadLog";
                string statusFilter = ddlStatusFilter.SelectedValue;
                
                if (!string.IsNullOrEmpty(statusFilter))
                {
                    query += " WHERE Status = @Status";
                }
                
                query += " ORDER BY CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        cmd.Parameters.AddWithValue("@Status", statusFilter);
                    }

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        gvLogs.DataSource = dt;
                        gvLogs.DataBind();
                    }
                }
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
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
