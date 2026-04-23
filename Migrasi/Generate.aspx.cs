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
    public partial class Generate : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                FillConfigDropdown();
            }
        }

        private void FillConfigDropdown()
        {
            string connString = ConfigurationManager.ConnectionStrings["SimulasiDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT FileGenerate, NamaSPGenerate FROM T_MaintenanceGenerate ORDER BY FileGenerate";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    ddlConfig.DataSource = cmd.ExecuteReader();
                    ddlConfig.DataBind();
                    ddlConfig.Items.Insert(0, new ListItem("-- Select Configuration --", ""));
                }
            }
        }

        protected void btnPreview_Click(object sender, EventArgs e)
        {
            if (ddlConfig.SelectedIndex == 0)
            {
                Response.Write("<script>alert('Please select a configuration first.');</script>");
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
                if (pageCount > 1)
                {
                    List<int> pages = Enumerable.Range(1, pageCount).ToList();
                    rptPager.DataSource = pages;
                    rptPager.DataBind();
                }
                else
                {
                    rptPager.DataSource = null;
                    rptPager.DataBind();
                }
            }
        }

        protected void rptPager_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int pageIndex = int.Parse(e.CommandArgument.ToString()) - 1;
            gvProducts.PageIndex = pageIndex;
            BindGrid();
        }

        private DataTable GetData()
        {
            string spName = ddlConfig.SelectedValue;
            if (string.IsNullOrEmpty(spName)) return null;

            string connString = ConfigurationManager.ConnectionStrings["SimulasiDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(spName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
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
                            Response.Write("<script>alert('Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
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
                Response.Write("<script>alert('Please select a configuration first.');</script>");
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
                Response.Charset = "";
                Response.ContentType = "application/text";
                Response.Output.Write(sb.ToString());
                Response.Flush();
                Response.End();
            }
            else
            {
                Response.Write("<script>alert('No data found to generate.');</script>");
            }
        }
    }
}
