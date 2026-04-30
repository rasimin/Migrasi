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
                    ViewState["UploadFileName"] = fileUpload.FileName; // Persist filename
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
            string fileName = ViewState["UploadFileName"] as string ?? "Unknown";
            string spName = ddlConfig.SelectedValue;

            if (dt == null || string.IsNullOrEmpty(spName)) { ShowAlert("Data lost. Please preview the file again."); return; }

            int successCount = 0;
            int errorCount = 0;
            string lastError = "";
            int configID = 0;

            // Fetch ConfigID and TargetDB if configured
            string targetDb = "";
            try
            {
                using (SqlConnection connConfig = new SqlConnection(connString))
                {
                    string queryConfig = "SELECT ID, TargetDB FROM T_MaintenanceGenerate WHERE NamaSPUpload = @SPName";
                    using (SqlCommand cmdConfig = new SqlCommand(queryConfig, connConfig))
                    {
                        cmdConfig.Parameters.AddWithValue("@SPName", spName);
                        connConfig.Open();
                        using (SqlDataReader reader = cmdConfig.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                configID = Convert.ToInt32(reader["ID"]);
                                if (reader["TargetDB"] != null && reader["TargetDB"] != DBNull.Value)
                                {
                                    targetDb = reader["TargetDB"].ToString();
                                }
                            }
                        }
                    }
                }
            }
            catch { /* Ignore error, fallback to default */ }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                if (!string.IsNullOrEmpty(targetDb))
                {
                    conn.ChangeDatabase(targetDb);
                }

                // Fetch Custom Mapping if exists
                Dictionary<string, string> mappings = new Dictionary<string, string>();
                using (SqlConnection connMap = new SqlConnection(ConfigurationManager.ConnectionStrings["SimulasiDB"].ConnectionString))
                {
                    string queryMap = "SELECT SourceColumn, TargetParameter FROM T_MappingDetail WHERE ConfigID = @CID";
                    using (SqlCommand cmdMap = new SqlCommand(queryMap, connMap))
                    {
                        cmdMap.Parameters.AddWithValue("@CID", configID);
                        connMap.Open();
                        using (SqlDataReader rMap = cmdMap.ExecuteReader())
                        {
                            while (rMap.Read())
                            {
                                mappings[rMap["TargetParameter"].ToString()] = rMap["SourceColumn"].ToString();
                            }
                        }
                    }
                }
                
                foreach (DataRow row in dt.Rows)
                {
                    string currentRawData = string.Join("|", row.ItemArray);
                    string status = "SUCCESS";
                    string errorMsg = "";
                    string fullSqlScript = "";

                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(spName, conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            
                            if (mappings.Count > 0)
                            {
                                // Use Custom Mapping
                                foreach (var m in mappings)
                                {
                                    // Ensure column exists in TXT file
                                    if (dt.Columns.Contains(m.Value))
                                    {
                                        string val = row[m.Value].ToString();
                                        if (string.IsNullOrWhiteSpace(val))
                                        {
                                            cmd.Parameters.AddWithValue(m.Key, DBNull.Value);
                                        }
                                        else
                                        {
                                            decimal d;
                                            if (decimal.TryParse(val, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out d))
                                                cmd.Parameters.AddWithValue(m.Key, d);
                                            else
                                                cmd.Parameters.AddWithValue(m.Key, val);
                                        }
                                    }
                                }
                            }
                            else
                            {
                                // Default: Map each column to SP parameter by name
                                foreach (DataColumn col in dt.Columns)
                                {
                                    string paramName = "@" + col.ColumnName;
                                    string val = row[col.ColumnName].ToString();
                                    if (string.IsNullOrWhiteSpace(val))
                                    {
                                        cmd.Parameters.AddWithValue(paramName, DBNull.Value);
                                    }
                                    else
                                    {
                                        decimal d;
                                        if (decimal.TryParse(val, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out d))
                                            cmd.Parameters.AddWithValue(paramName, d);
                                        else
                                            cmd.Parameters.AddWithValue(paramName, val);
                                    }
                                }
                            }

                            // Capture formatted SQL for logging
                            fullSqlScript = GetFullSqlCommand(cmd);

                            cmd.ExecuteNonQuery();
                            successCount++;
                        }
                    }
                    catch (Exception ex)
                    {
                        errorCount++;
                        status = "FAILED";
                        errorMsg = ex.Message;
                        lastError = ex.Message;
                    }

                    // Insert Log into T_UploadLog
                    try
                    {
                        using (SqlConnection connLog = new SqlConnection(connString))
                        {
                            string queryLog = "INSERT INTO T_UploadLog (ConfigID, FileName, RawData, Status, ErrorMessage, ScriptExecuted) VALUES (@CID, @FN, @RD, @ST, @EM, @SX)";
                            using (SqlCommand cmdLog = new SqlCommand(queryLog, connLog))
                            {
                                cmdLog.Parameters.AddWithValue("@CID", configID);
                                cmdLog.Parameters.AddWithValue("@FN", fileName);
                                cmdLog.Parameters.AddWithValue("@RD", currentRawData);
                                cmdLog.Parameters.AddWithValue("@ST", status);
                                cmdLog.Parameters.AddWithValue("@EM", errorMsg);
                                cmdLog.Parameters.AddWithValue("@SX", fullSqlScript);
                                connLog.Open();
                                cmdLog.ExecuteNonQuery();
                            }
                        }
                    }
                    catch { /* Fail silently if logging fails to prevent stopping the upload */ }
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

        private string GetFullSqlCommand(SqlCommand cmd)
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("EXEC ").Append(cmd.CommandText).Append(" ");
            
            bool first = true;
            foreach (SqlParameter param in cmd.Parameters)
            {
                if (!first) sb.Append(", ");
                
                sb.Append(param.ParameterName).Append(" = ");
                
                if (param.Value == null || param.Value == DBNull.Value)
                {
                    sb.Append("NULL");
                }
                else if (param.Value is DateTime)
                {
                    sb.Append("'").Append(Convert.ToDateTime(param.Value).ToString("yyyy-MM-dd HH:mm:ss")).Append("'");
                }
                else if (param.Value is string)
                {
                    string valStr = param.Value.ToString();
                    // If it's a number, don't wrap in quotes for the log
                    if (decimal.TryParse(valStr, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out _))
                    {
                        sb.Append(valStr);
                    }
                    else
                    {
                        sb.Append("'").Append(valStr.Replace("'", "''")).Append("'");
                    }
                }
                else
                {
                    sb.Append(param.Value.ToString());
                }
                first = false;
            }
            return sb.ToString();
        }
    }
}
