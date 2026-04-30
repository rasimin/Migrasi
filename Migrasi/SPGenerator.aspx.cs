using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Migrasi
{
    public partial class SPGenerator : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.FileUpload fileUpload;
        protected global::System.Web.UI.WebControls.TextBox txtSPName;
        protected global::System.Web.UI.WebControls.TextBox txtResult;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl resultArea;

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            if (!fileUpload.HasFile)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showAlert('Error', 'Please select a sample TXT file first', 'error');", true);
                return;
            }

            try
            {
                string spName = string.IsNullOrEmpty(txtSPName.Text) ? "usp_UploadData" : txtSPName.Text.Trim();
                
                using (StreamReader reader = new StreamReader(fileUpload.FileContent))
                {
                    string headerLine = reader.ReadLine();
                    if (string.IsNullOrEmpty(headerLine))
                    {
                        throw new Exception("The file is empty or invalid.");
                    }

                    string[] headers = headerLine.Split('|');
                    
                    // Validasi: Cek jika ada nama kolom yang duplikat
                    var duplicates = headers.Select(h => h.Trim().Replace(" ", "_"))
                                            .GroupBy(x => x)
                                            .Where(g => g.Count() > 1)
                                            .Select(y => y.Key)
                                            .ToList();

                    if (duplicates.Any())
                    {
                        throw new Exception($"Failed! Duplicate column names detected: {string.Join(", ", duplicates)}.");
                    }

                    // Read all rows to find the best data type for each column
                    List<string[]> allRows = new List<string[]>();
                    while (!reader.EndOfStream)
                    {
                        string line = reader.ReadLine();
                        if (!string.IsNullOrWhiteSpace(line))
                        {
                            allRows.Add(line.Split('|'));
                        }
                    }

                    StringBuilder sb = new StringBuilder();
                    sb.AppendLine($"/****** Object:  StoredProcedure [dbo].[{spName}] ******/");
                    sb.AppendLine($"CREATE PROCEDURE [dbo].[{spName}]");
                    
                    // Parameters
                    for (int i = 0; i < headers.Length; i++)
                    {
                        string colName = headers[i].Trim().Replace(" ", "_");
                        
                        // Find a non-empty sample for this column across all rows
                        string bestSample = "";
                        foreach (var row in allRows)
                        {
                            if (row.Length > i && !string.IsNullOrWhiteSpace(row[i]))
                            {
                                bestSample = row[i];
                                break; // Found first non-null data
                            }
                        }

                        string dataType = GuessDataType(bestSample);
                        
                        string comma = (i == headers.Length - 1) ? "" : ",";
                        sb.AppendLine($"    @{colName} {dataType}{comma}");
                    }

                    sb.AppendLine("AS");
                    sb.AppendLine("BEGIN");
                    sb.AppendLine("    SET NOCOUNT ON;");
                    sb.AppendLine("");
                    sb.AppendLine("    -- TODO: Define your target table and mapping here");
                    sb.AppendLine("    /*");
                    sb.AppendLine("    INSERT INTO YourTargetTable (");
                    for (int i = 0; i < headers.Length; i++)
                    {
                        string colName = headers[i].Trim().Replace(" ", "_");
                        string comma = (i == headers.Length - 1) ? "" : ",";
                        sb.AppendLine($"        [{colName}]{comma}");
                    }
                    sb.AppendLine("    )");
                    sb.AppendLine("    VALUES (");
                    for (int i = 0; i < headers.Length; i++)
                    {
                        string colName = headers[i].Trim().Replace(" ", "_");
                        string comma = (i == headers.Length - 1) ? "" : ",";
                        sb.AppendLine($"        @{colName}{comma}");
                    }
                    sb.AppendLine("    )");
                    sb.AppendLine("    */");
                    sb.AppendLine("END");

                    txtResult.Text = sb.ToString();
                    resultArea.Visible = true;
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"showAlert('Error', '{ex.Message.Replace("'", "")}', 'error');", true);
            }
        }

        private string GuessDataType(string sample)
        {
            if (string.IsNullOrWhiteSpace(sample)) return "VARCHAR(500)";

            sample = sample.Trim();

            // Check for Numeric/Decimal
            decimal d;
            if (decimal.TryParse(sample, out d))
            {
                // If it contains a dot, it's definitely a decimal
                if (sample.Contains(".") || sample.Contains(","))
                    return "DECIMAL(18, 4)";
                
                return "INT";
            }

            // Check for DateTime
            DateTime dt;
            if (DateTime.TryParse(sample, out dt))
            {
                return "DATETIME";
            }

            return "VARCHAR(500)";
        }
    }
}
