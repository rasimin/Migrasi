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
    public partial class DatabaseMaster : Page
    {
        protected global::System.Web.UI.WebControls.GridView gvDatabases;
        protected global::System.Web.UI.WebControls.TextBox txtNewDBName;
        protected global::System.Web.UI.WebControls.TextBox txtNewDescription;

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
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // Pastikan tabel sudah ada (hindari error page crash)
                    string checkTableQuery = "IF OBJECT_ID('TDatabaseMaster', 'U') IS NOT NULL SELECT 1 ELSE SELECT 0";
                    using (SqlCommand cmdCheck = new SqlCommand(checkTableQuery, conn))
                    {
                        conn.Open();
                        int exists = (int)cmdCheck.ExecuteScalar();
                        if (exists == 0)
                        {
                            ShowMessage("Table TDatabaseMaster does not exist. Please run the SQL Script shown above.", "warning");
                            return;
                        }
                    }

                    string query = "SELECT ID, DBName, Description, IsActive FROM TDatabaseMaster ORDER BY DBName";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            gvDatabases.DataSource = dt;
                            gvDatabases.DataBind();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading data: " + ex.Message, "error");
            }
        }

        protected void btnSync_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    
                    // 1. Ambil semua database dari SQL Server
                    string getDbQuery = "SELECT name FROM sys.databases WHERE state_desc = 'ONLINE'";
                    List<string> serverDbs = new List<string>();
                    using (SqlCommand cmdGet = new SqlCommand(getDbQuery, conn))
                    {
                        using (SqlDataReader reader = cmdGet.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                serverDbs.Add(reader["name"].ToString());
                            }
                        }
                    }

                    // 2. Insert ke TDatabaseMaster jika belum ada
                    int addedCount = 0;
                    foreach (string dbName in serverDbs)
                    {
                        string checkQuery = "SELECT COUNT(1) FROM TDatabaseMaster WHERE DBName = @DBName";
                        using (SqlCommand cmdCheck = new SqlCommand(checkQuery, conn))
                        {
                            cmdCheck.Parameters.AddWithValue("@DBName", dbName);
                            int count = (int)cmdCheck.ExecuteScalar();
                            
                            if (count == 0)
                            {
                                string insertQuery = "INSERT INTO TDatabaseMaster (DBName, Description, IsActive) VALUES (@DBName, @Desc, 1)";
                                using (SqlCommand cmdInsert = new SqlCommand(insertQuery, conn))
                                {
                                    cmdInsert.Parameters.AddWithValue("@DBName", dbName);
                                    cmdInsert.Parameters.AddWithValue("@Desc", "Auto-synced from Server");
                                    cmdInsert.ExecuteNonQuery();
                                    addedCount++;
                                }
                            }
                        }
                    }

                    BindGrid();
                    ShowMessage($"Sync complete! {addedCount} new databases added.", "success");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Sync failed (Check permissions to sys.databases): " + ex.Message, "error");
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string dbName = txtNewDBName.Text.Trim();
            string desc = txtNewDescription.Text.Trim();

            if (string.IsNullOrEmpty(dbName))
            {
                ShowMessage("Database Name is required.", "warning");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "INSERT INTO TDatabaseMaster (DBName, Description, IsActive) VALUES (@DBName, @Desc, 1)";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@DBName", dbName);
                        cmd.Parameters.AddWithValue("@Desc", desc);
                        
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                
                txtNewDBName.Text = "";
                txtNewDescription.Text = "";
                BindGrid();
                
                // Hide modal via JS
                ClientScript.RegisterStartupScript(this.GetType(), "hideModal", "var myModal = bootstrap.Modal.getInstance(document.getElementById('addModal')); myModal.hide();", true);
                ShowMessage("Database added successfully!", "success");
            }
            catch (SqlException ex) when (ex.Number == 2627) // Unique constraint violation
            {
                ShowMessage("Database name already exists in the master table.", "warning");
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving data: " + ex.Message, "error");
            }
        }

        protected void gvDatabases_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvDatabases.EditIndex = e.NewEditIndex;
            BindGrid();
        }

        protected void gvDatabases_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvDatabases.EditIndex = -1;
            BindGrid();
        }

        protected void gvDatabases_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int id = Convert.ToInt32(gvDatabases.DataKeys[e.RowIndex].Value);
            TextBox txtDBName = (TextBox)gvDatabases.Rows[e.RowIndex].FindControl("txtDBName");
            TextBox txtDescription = (TextBox)gvDatabases.Rows[e.RowIndex].FindControl("txtDescription");
            CheckBox chkIsActive = (CheckBox)gvDatabases.Rows[e.RowIndex].FindControl("chkIsActive");

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "UPDATE TDatabaseMaster SET DBName = @DBName, Description = @Desc, IsActive = @IsActive WHERE ID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@DBName", txtDBName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Desc", txtDescription.Text.Trim());
                        cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                        cmd.Parameters.AddWithValue("@ID", id);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                
                gvDatabases.EditIndex = -1;
                BindGrid();
                ShowMessage("Record updated successfully!", "success");
            }
            catch (SqlException ex) when (ex.Number == 2627)
            {
                ShowMessage("Update failed: Database name already exists.", "warning");
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating data: " + ex.Message, "error");
            }
        }

        protected void gvDatabases_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvDatabases.DataKeys[e.RowIndex].Value);

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM TDatabaseMaster WHERE ID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", id);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                BindGrid();
                ShowMessage("Record deleted successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting data: " + ex.Message, "error");
            }
        }

        private void ShowMessage(string message, string type = "info")
        {
            ClientScript.RegisterStartupScript(this.GetType(), "alert", $"showAlert('{type.ToUpper()}', '{message.Replace("'", "\\'")}', '{type}');", true);
        }
    }
}
