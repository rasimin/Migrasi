using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Diagnostics;

namespace Migrasi
{
    public partial class Query : Page
    {
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
                    // Query untuk menarik daftar database yang aktif (tidak offline/restoring)
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
                    
                    // Set dropdown ke database bawaan dari connection string
                    string defaultDb = conn.Database;
                    if (ddlDatabase.Items.FindByValue(defaultDb) != null)
                    {
                        ddlDatabase.SelectedValue = defaultDb;
                    }
                }
            }
            catch (Exception)
            {
                // Fallback: Jika user tidak punya izin (VIEW ANY DATABASE) untuk membaca sys.databases,
                // tangkap errornya diam-diam dan cukup tampilkan 1 database bawaan dari connection string.
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
                catch
                {
                    // Ignore ultimate fallback error
                }
            }
        }

        protected void btnExecute_Click(object sender, EventArgs e)
        {
            string query = txtQuery.Text.Trim();
            if (string.IsNullOrEmpty(query))
            {
                ShowMessage("Please enter a SQL command.", "warning");
                return;
            }

            Stopwatch sw = new Stopwatch();
            sw.Start();

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    System.Text.StringBuilder sqlOutput = new System.Text.StringBuilder();
                    conn.InfoMessage += (s, ev) => {
                        sqlOutput.AppendLine(ev.Message);
                    };

                    conn.Open(); // Buka koneksi terlebih dahulu

                    // Ganti fokus database sesuai dengan pilihan dropdown
                    string selectedDb = ddlDatabase.SelectedValue;
                    if (!string.IsNullOrEmpty(selectedDb) && !selectedDb.Equals(conn.Database, StringComparison.OrdinalIgnoreCase))
                    {
                        conn.ChangeDatabase(selectedDb);
                    }

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        // Batasi waktu eksekusi maksimal 3 menit (180 detik)
                        cmd.CommandTimeout = 180;
                        
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataSet ds = new DataSet();
                            try 
                            {
                                sda.Fill(ds);
                                
                                phGrids.Controls.Clear();
                                int tableCount = 0;

                                foreach (DataTable dt in ds.Tables)
                                {
                                    if (dt.Columns.Count > 0)
                                    {
                                        tableCount++;
                                        
                                        // Wrapper for the result set and its export button
                                        phGrids.Controls.Add(new LiteralControl("<div class='result-set-wrapper mb-5'>"));

                                        // Header row with Label and Export Button
                                        string headerHtml = $@"
                                            <div class='d-flex justify-content-between align-items-center mb-2'>
                                                <div class='badge bg-primary px-3 py-2'>Result Set #{tableCount}</div>
                                                <button type='button' class='btn btn-outline-success btn-sm border-2 fw-bold shadow-sm' onclick='exportToCSV(this)'>
                                                    <i class='bi bi-file-earmark-spreadsheet me-1'></i> EXPORT CSV
                                                </button>
                                            </div>";
                                        phGrids.Controls.Add(new LiteralControl(headerHtml));

                                        Panel pnl = new Panel();
                                        pnl.CssClass = "table-responsive rounded-3 border shadow-sm";
                                        pnl.Style.Add("max-height", "400px");

                                        GridView gv = new GridView();
                                        gv.ID = "gvResults_" + tableCount;
                                        gv.AutoGenerateColumns = true;
                                        gv.CssClass = "table table-hover table-modern mb-0";
                                        gv.GridLines = GridLines.None;
                                        gv.DataSource = dt;
                                        gv.DataBind();

                                        pnl.Controls.Add(gv);
                                        phGrids.Controls.Add(pnl);
                                        phGrids.Controls.Add(new LiteralControl("</div>")); // Close wrapper
                                    }
                                }

                                string finalMsg = sqlOutput.Length > 0 ? sqlOutput.ToString() + "\n" : "";

                                if (tableCount > 0)
                                {
                                    litEmpty.Visible = false;
                                    sw.Stop();
                                    ShowMessage(finalMsg + $"Query executed successfully. ({tableCount} result sets, {sw.ElapsedMilliseconds} ms)", "success");
                                    ScriptManager.RegisterStartupScript(this, GetType(), "switchTab", "switchTab('results-tab');", true);
                                }
                                else
                                {
                                    litEmpty.Visible = true;
                                    sw.Stop();
                                    ShowMessage(finalMsg + $"Command executed successfully. ({sw.ElapsedMilliseconds} ms)", "success");
                                    ScriptManager.RegisterStartupScript(this, GetType(), "switchTab", "switchTab('messages-tab');", true);
                                }
                            }
                            catch
                            {
                                int affectedRows = cmd.ExecuteNonQuery();
                                string finalMsg = sqlOutput.Length > 0 ? sqlOutput.ToString() + "\n" : "";
                                litEmpty.Visible = true;
                                sw.Stop();
                                ShowMessage(finalMsg + $"Command executed successfully. ({affectedRows} rows affected, {sw.ElapsedMilliseconds} ms)", "success");
                                ScriptManager.RegisterStartupScript(this, GetType(), "switchTab", "switchTab('messages-tab');", true);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                sw.Stop();
                ShowMessage($"Error: {ex.Message}", "danger");
                ScriptManager.RegisterStartupScript(this, GetType(), "switchTab", "switchTab('messages-tab');", true);
            }
        }

        private void ShowMessage(string msg, string type)
        {
            string icon = type == "danger" ? "exclamation-triangle-fill" : "check-circle-fill";
            if (type == "warning") icon = "exclamation-circle-fill";

            litMessages.Text = $@"
                <div class='alert alert-{type} d-flex align-items-center shadow-sm border-0 mb-0' role='alert'>
                    <i class='bi bi-{icon} me-3 fs-4'></i>
                    <div>
                        <div class='fw-bold'>System Message</div>
                        <div class='small font-monospace'>{msg.Replace("\n", "<br/>")}</div>
                    </div>
                </div>";
        }
    }
}
