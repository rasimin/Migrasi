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
    public partial class Maintenance : Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SimulasiDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDatabases();
                BindGrid();
            }
        }

        private void LoadDatabases()
        {
            ddlTargetDB.Items.Clear();
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT name FROM sys.databases WHERE state_desc = 'ONLINE' ORDER BY name";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            ddlTargetDB.DataSource = reader;
                            ddlTargetDB.DataTextField = "name";
                            ddlTargetDB.DataValueField = "name";
                            ddlTargetDB.DataBind();
                        }
                    }
                }
            }
            catch
            {
                try
                {
                    SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connString);
                    string defaultDb = builder.InitialCatalog;
                    if (!string.IsNullOrEmpty(defaultDb))
                    {
                        ddlTargetDB.Items.Add(new ListItem(defaultDb, defaultDb));
                    }
                }
                catch { }
            }
            
            // Tambahkan opsi default kosong
            ddlTargetDB.Items.Insert(0, new ListItem("-- Default (Connection String) --", ""));
        }

        private void BindGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT * FROM T_MaintenanceGenerate ORDER BY CreatedAt DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        gvMaintenance.DataSource = dt;
                        gvMaintenance.DataBind();
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int id = int.Parse(hfID.Value);
            string fileName = txtFileName.Text.Trim();
            string spName = txtSPName.Text.Trim();
            string spUpload = txtSPUpload.Text.Trim();
            string targetDb = ddlTargetDB.SelectedValue;

            if (string.IsNullOrEmpty(fileName) || string.IsNullOrEmpty(spName))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showAlert('Wait', 'Please fill all fields', 'warning');", true);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "";
                if (id == 0)
                    query = "INSERT INTO T_MaintenanceGenerate (FileGenerate, NamaSPGenerate, NamaSPUpload, TargetDB) VALUES (@File, @SP, @SPUp, @TargetDB)";
                else
                    query = "UPDATE T_MaintenanceGenerate SET FileGenerate = @File, NamaSPGenerate = @SP, NamaSPUpload = @SPUp, TargetDB = @TargetDB WHERE ID = @ID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@File", fileName);
                    cmd.Parameters.AddWithValue("@SP", spName);
                    cmd.Parameters.AddWithValue("@SPUp", (object)spUpload ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@TargetDB", string.IsNullOrEmpty(targetDb) ? DBNull.Value : (object)targetDb);
                    
                    if (id != 0) cmd.Parameters.AddWithValue("@ID", id);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                    conn.Close();
                }
            }

            ResetForm();
            BindGrid();
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showAlert('Success', 'Data saved successfully', 'success');", true);
        }

        protected void gvMaintenance_RowEditing(object sender, GridViewEditEventArgs e)
        {
            int id = Convert.ToInt32(gvMaintenance.DataKeys[e.NewEditIndex].Value);
            LoadDataToForm(id);
            e.Cancel = true; // Prevent default editing mode
            ScriptManager.RegisterStartupScript(this, GetType(), "showModal", "showModal();", true);
        }

        private void LoadDataToForm(int id)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT * FROM T_MaintenanceGenerate WHERE ID = @ID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            hfID.Value = dr["ID"].ToString();
                            txtFileName.Text = dr["FileGenerate"].ToString();
                            txtSPName.Text = dr["NamaSPGenerate"].ToString();
                            txtSPUpload.Text = dr["NamaSPUpload"].ToString();
                            
                            string targetDb = dr["TargetDB"] != DBNull.Value ? dr["TargetDB"].ToString() : "";
                            if (ddlTargetDB.Items.FindByValue(targetDb) != null)
                            {
                                ddlTargetDB.SelectedValue = targetDb;
                            }
                            else
                            {
                                ddlTargetDB.SelectedIndex = 0;
                            }
                        }
                    }
                }
            }
        }

        protected void gvMaintenance_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvMaintenance.DataKeys[e.RowIndex].Value);
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "DELETE FROM T_MaintenanceGenerate WHERE ID = @ID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    conn.Close();
                }
            }
            BindGrid();
        }

        private void ResetForm()
        {
            hfID.Value = "0";
            txtFileName.Text = "";
            txtSPName.Text = "";
            txtSPUpload.Text = "";
            ddlTargetDB.SelectedIndex = 0;
        }
    }
}
