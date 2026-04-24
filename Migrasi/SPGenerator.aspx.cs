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
                    string dataLine = reader.ReadLine();

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
                        throw new Exception($"Failed! Duplicate column names detected: {string.Join(", ", duplicates)}. All columns in the file must have unique names.");
                    }

                    string[] samples = !string.IsNullOrEmpty(dataLine) ? dataLine.Split('|') : new string[headers.Length];

                    StringBuilder sb = new StringBuilder();
                    sb.AppendLine($"/****** Object:  StoredProcedure [dbo].[{spName}] ******/");
                    sb.AppendLine($"CREATE PROCEDURE [dbo].[{spName}]");
                    
                    // Parameters
                    for (int i = 0; i < headers.Length; i++)
                    {
                        string colName = headers[i].Trim().Replace(" ", "_");
                        string dataType = GuessDataType(samples.Length > i ? samples[i] : "");
                        
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
                    sb.AppendLine("");
                    sb.AppendLine("    -- Optional: Return success message");
                    sb.AppendLine("    -- PRINT 'Data inserted successfully';");
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
