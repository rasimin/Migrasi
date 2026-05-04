using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Text;

namespace Migrasi
{
    public class PagerItem
    {
        public string Text { get; set; }
        public string Value { get; set; }
        public bool IsActive { get; set; }
    }

    public partial class Generate : Page
    {
        string connString = ConnectionHelper.GetActiveConnectionString();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                FillConfigDropdown();
            }
        }

        private void FillConfigDropdown()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT ID, FileGenerate FROM T_MaintenanceGenerate ORDER BY FileGenerate";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        ddlConfig.DataSource = cmd.ExecuteReader();
                        ddlConfig.DataBind();
                        ddlConfig.Items.Insert(0, new ListItem("-- Select Configuration --", ""));
                    }
                }
            }
            catch (Exception ex)
            {
                ddlConfig.Items.Insert(0, new ListItem("-- Error Loading Config --", ""));
                if (ex.Message.Contains("T_MaintenanceGenerate"))
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", "showAlert('Setup Required', 'Table T_MaintenanceGenerate is missing. Please run the SQL Setup script first.', 'warning');", true);
                }
            }
        }

        protected void btnPreview_Click(object sender, EventArgs e)
        {
            if (ddlConfig.SelectedIndex == 0)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "showAlert('Wait', 'Please select a configuration first.', 'warning');", true);
                return;
            }
            BindGrid();
        }

        protected void gvProducts_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProducts.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        private void BindGrid()
        {
            DataTable dt = GetData();
            if (dt != null)
            {
                gvProducts.DataSource = dt;
                gvProducts.DataBind();
                
                // Show Total Records
                lblTotal.Text = "Total Records: " + dt.Rows.Count.ToString("N0");
                lblTotal.Visible = true;

                // Set Up Custom Pager
                int pageCount = gvProducts.PageCount;
                int currentPage = gvProducts.PageIndex;

                if (pageCount > 1)
                {
                    List<PagerItem> pages = new List<PagerItem>();
                    
                    // Always show 5 pages around current page if possible
                    int start = Math.Max(0, currentPage - 2);
                    int end = Math.Min(pageCount - 1, start + 4);
                    
                    // Adjust start if end is at the limit
                    if (end == pageCount - 1) start = Math.Max(0, end - 4);

                    for (int i = start; i <= end; i++)
                    {
                        pages.Add(new PagerItem { 
                            Text = (i + 1).ToString(), 
                            Value = (i + 1).ToString(), 
                            IsActive = (i == currentPage) 
                        });
                    }
                    
                    rptPager.DataSource = pages;
                    rptPager.DataBind();

                    // Update Navigation Buttons
                    btnFirst.Enabled = currentPage > 0;
                    btnPrev.Enabled = currentPage > 0;
                    btnNext.Enabled = currentPage < pageCount - 1;
                    btnLast.Enabled = currentPage < pageCount - 1;

                    btnFirst.CssClass = "btn-page shadow-sm" + (currentPage == 0 ? " opacity-25" : "");
                    btnPrev.CssClass = "btn-page shadow-sm" + (currentPage == 0 ? " opacity-25" : "");
                    btnNext.CssClass = "btn-page shadow-sm" + (currentPage == pageCount - 1 ? " opacity-25" : "");
                    btnLast.CssClass = "btn-page shadow-sm" + (currentPage == pageCount - 1 ? " opacity-25" : "");
                }
                else
                {
                    rptPager.DataSource = null;
                    rptPager.DataBind();
                    btnFirst.Visible = btnPrev.Visible = btnNext.Visible = btnLast.Visible = false;
                }
            }
        }

        protected void rptPager_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int pageIndex = int.Parse(e.CommandArgument.ToString()) - 1;
            gvProducts.PageIndex = pageIndex;
            BindGrid();
        }

        protected void Pager_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string arg = btn.CommandArgument;
            int pageCount = gvProducts.PageCount;

            switch (arg)
            {
                case "First": gvProducts.PageIndex = 0; break;
                case "Prev": gvProducts.PageIndex = Math.Max(0, gvProducts.PageIndex - 1); break;
                case "Next": gvProducts.PageIndex = Math.Min(pageCount - 1, gvProducts.PageIndex + 1); break;
                case "Last": gvProducts.PageIndex = pageCount - 1; break;
            }
            BindGrid();
        }

        private DataTable GetData()
        {
            string configIdStr = ddlConfig.SelectedValue;
            if (string.IsNullOrEmpty(configIdStr)) return null;
            
            int configId = 0;
            if (!int.TryParse(configIdStr, out configId)) return null;

            string connString = ConnectionHelper.GetActiveConnectionString();
            
            // Fetch configuration details dynamically
            string targetDb = "";
            string generateType = "SP";
            string spName = "";
            
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string queryConfig = "SELECT NamaSPGenerate, TargetDB, GenerateType FROM T_MaintenanceGenerate WHERE ID = @ID";
                    using (SqlCommand cmd = new SqlCommand(queryConfig, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", configId);
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                spName = reader["NamaSPGenerate"].ToString();
                                
                                if (reader["TargetDB"] != DBNull.Value)
                                    targetDb = reader["TargetDB"].ToString();
                                    
                                if (reader["GenerateType"] != DBNull.Value)
                                    generateType = reader["GenerateType"].ToString();
                            }
                        }
                    }
                }
            }
            catch { return null; }

            if (string.IsNullOrEmpty(spName)) return null;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                if (!string.IsNullOrEmpty(targetDb))
                {
                    conn.ChangeDatabase(targetDb);
                }

                using (SqlCommand cmd = new SqlCommand(spName, conn))
                {
                    cmd.CommandType = generateType == "Plain SQL" ? CommandType.Text : CommandType.StoredProcedure;
                    cmd.CommandTimeout = 180; // Add timeout
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            sda.Fill(dt);
                            return dt;
                        }
                        catch (Exception ex)
                        {
                            ClientScript.RegisterStartupScript(this.GetType(), "alert", "showAlert('Database Error', '" + ex.Message.Replace("'", "\\'") + "', 'error');", true);
                            return null;
                        }
                    }
                }
            }
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            if (ddlConfig.SelectedIndex == 0)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "showAlert('Wait', 'Please select a configuration first.', 'warning');", true);
                return;
            }

            DataTable dt = GetData();
            if (dt != null && dt.Rows.Count > 0)
            {
                StringBuilder sb = new StringBuilder();

                // Column Headers
                string[] columnNames = dt.Columns.Cast<DataColumn>().Select(column => column.ColumnName).ToArray();
                sb.AppendLine(string.Join("|", columnNames));

                // Rows
                foreach (DataRow row in dt.Rows)
                {
                    List<string> fields = new List<string>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        object value = row[col];
                        string fieldString = "";

                        if (value == DBNull.Value || value == null)
                        {
                            fieldString = "";
                        }
                        else if (value is DateTime)
                        {
                            // Standard ISO Date format for reliable upload
                            fieldString = ((DateTime)value).ToString("yyyy-MM-dd HH:mm:ss");
                        }
                        else if (value is bool)
                        {
                            // Output boolean as 1 or 0 instead of True/False for safer SQL parsing
                            fieldString = ((bool)value) ? "1" : "0";
                        }
                        else
                        {
                            fieldString = value.ToString();
                            // Clean up characters that could break the TXT structure
                            fieldString = fieldString.Replace("|", " ") // Remove delimiter from data
                                                   .Replace("\r", " ")  // Remove carriage returns
                                                   .Replace("\n", " "); // Remove newlines
                        }
                        fields.Add(fieldString);
                    }
                    sb.AppendLine(string.Join("|", fields));
                }

                // Use the file name from dropdown (text of the selected item)
                string selectedFileName = ddlConfig.SelectedItem.Text;
                if (!selectedFileName.EndsWith(".txt")) selectedFileName += ".txt";

                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=" + selectedFileName);
                // Set a cookie so the client knows the download has finished
                Response.Cookies.Add(new HttpCookie("fileDownload", "true") { Path = "/" });
                Response.Charset = "";
                Response.ContentType = "application/text";
                Response.Output.Write(sb.ToString());
                Response.Flush();
                Response.End();
            }
            else
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "showAlert('Information', 'No data found to generate.', 'info');", true);
            }
        }
    }
}
