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

namespace Migrasi
{
    public partial class Upload : Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SimulasiDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                FillConfigDropdown();
            }
        }

        private void FillConfigDropdown()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT FileGenerate, NamaSPUpload FROM T_MaintenanceGenerate WHERE NamaSPUpload IS NOT NULL AND NamaSPUpload <> '' ORDER BY FileGenerate";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    ddlConfig.DataSource = cmd.ExecuteReader();
                    ddlConfig.DataBind();
                    ddlConfig.Items.Insert(0, new ListItem("-- Select Upload Config --", ""));
                }
            }
        }

        protected void btnPreview_Click(object sender, EventArgs e)
        {
            if (ddlConfig.SelectedIndex == 0) { ShowAlert("Please select a configuration first.", "warning"); return; }
            if (!fileUpload.HasFile) { ShowAlert("Please choose a file to upload.", "warning"); return; }

            try
            {
                DataTable dt = ParseTxtFile(fileUpload.FileContent);
                if (dt != null && dt.Rows.Count > 0)
                {
                    ViewState["UploadData"] = dt;
                    gvUploadPreview.DataSource = dt;
                    gvUploadPreview.DataBind();
                    lblTotal.Text = "Rows Found: " + dt.Rows.Count;
                    previewArea.Visible = true;
                }
                else
                {
                    ShowAlert("File is empty or not in correct format.");
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error reading file: " + ex.Message, "error");
            }
        }

        private DataTable ParseTxtFile(Stream fileStream)
        {
            DataTable dt = new DataTable();
            using (StreamReader sr = new StreamReader(fileStream))
            {
                string headerLine = sr.ReadLine();
                if (string.IsNullOrEmpty(headerLine)) return null;

                string[] headers = headerLine.Split('|');
                foreach (string header in headers)
                {
                    dt.Columns.Add(header.Trim());
                }

                while (!sr.EndOfStream)
                {
                    string rowsLine = sr.ReadLine();
                    if (!string.IsNullOrEmpty(rowsLine))
                    {
                        string[] rows = rowsLine.Split('|');
                        if (rows.Length == headers.Length)
                            dt.Rows.Add(rows);
                    }
                }
            }
            return dt;
        }

        protected void btnProcessUpload_Click(object sender, EventArgs e)
        {
            DataTable dt = ViewState["UploadData"] as DataTable;
            string spName = ddlConfig.SelectedValue;

            if (dt == null || string.IsNullOrEmpty(spName)) { ShowAlert("Data lost. Please preview the file again."); return; }

            int successCount = 0;
            int errorCount = 0;
            string lastError = "";

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                foreach (DataRow row in dt.Rows)
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(spName, conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            
                            // Map each column to SP parameter
                            foreach (DataColumn col in dt.Columns)
                            {
                                // Assumption: Parameter name in SP matches Column Name in TXT
                                string paramName = "@" + col.ColumnName;
                                cmd.Parameters.AddWithValue(paramName, row[col.ColumnName]);
                            }

                            cmd.ExecuteNonQuery();
                            successCount++;
                        }
                    }
                    catch (Exception ex)
                    {
                        errorCount++;
                        lastError = ex.Message;
                    }
                }
            }

            string resultMsg = $"Upload Finished.\\nSuccess: {successCount}\\nFailed: {errorCount}";
            if (errorCount > 0) resultMsg += "\\nLast Error: " + lastError.Replace("'", "");
            
            ShowAlert(resultMsg, errorCount > 0 ? "warning" : "success");
            
            if (errorCount == 0)
            {
                previewArea.Visible = false;
                ViewState["UploadData"] = null;
            }
        }

        private void ShowAlert(string msg, string type = "info")
        {
            string title = type == "error" ? "Error" : (type == "success" ? "Success" : "Information");
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"showAlert('{title}', '{msg.Replace("'", "\\'")}', '{type}');", true);
        }
    }
}
