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
    public partial class Mapping : Page
    {
        protected global::System.Web.UI.WebControls.GridView gvMapping;
        protected global::System.Web.UI.WebControls.HiddenField hfMappingId;
        protected global::System.Web.UI.WebControls.TextBox txtMappingKey;
        protected global::System.Web.UI.WebControls.TextBox txtFromCode;
        protected global::System.Web.UI.WebControls.TextBox txtToCode;

        string connString = ConnectionHelper.GetActiveConnectionString();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        private void LoadData()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT * FROM TMappingPadanan ORDER BY MappingKey, FromCode";
                    SqlDataAdapter sda = new SqlDataAdapter(query, conn);
                    DataTable dt = new DataTable();
                    sda.Fill(dt);
                    gvMapping.DataSource = dt;
                    gvMapping.DataBind();
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("TMappingPadanan"))
                {
                    ShowAlert("Setup Required", "Table TMappingPadanan is missing. Please run the SQL Setup script on this page.", "warning");
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string mappingId = hfMappingId.Value;
            string key = txtMappingKey.Text.Trim();
            string from = txtFromCode.Text.Trim();
            string to = txtToCode.Text.Trim();

            if (string.IsNullOrEmpty(key) || string.IsNullOrEmpty(from) || string.IsNullOrEmpty(to))
            {
                ShowAlert("Validation Error", "All fields are required.", "warning");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "";
                    if (string.IsNullOrEmpty(mappingId))
                    {
                        query = "INSERT INTO TMappingPadanan (MappingKey, FromCode, ToCode) VALUES (@Key, @From, @To)";
                    }
                    else
                    {
                        query = "UPDATE TMappingPadanan SET MappingKey = @Key, FromCode = @From, ToCode = @To WHERE id = @Id";
                    }

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@Key", key);
                    cmd.Parameters.AddWithValue("@From", from);
                    cmd.Parameters.AddWithValue("@To", to);
                    if (!string.IsNullOrEmpty(mappingId))
                    {
                        cmd.Parameters.AddWithValue("@Id", mappingId);
                    }

                    conn.Open();
                    cmd.ExecuteNonQuery();
                    
                    LoadData();
                    string actionMsg = string.IsNullOrEmpty(mappingId) ? "Mapping added successfully!" : "Mapping updated successfully!";
                    ShowAlert("Success", actionMsg, "success");
                }
            }
            catch (Exception ex)
            {
                string msg = ex.Message;
                if (msg.Contains("TMappingPadanan"))
                    msg = "Table 'TMappingPadanan' is missing. Please run the SQL Setup script first.";

                ShowAlert("Error", msg, "error");
            }
        }

        protected void gvMapping_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditMapping")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT * FROM TMappingPadanan WHERE id = @Id";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@Id", id);
                    conn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        hfMappingId.Value = dr["id"].ToString();
                        txtMappingKey.Text = dr["MappingKey"].ToString();
                        txtFromCode.Text = dr["FromCode"].ToString();
                        txtToCode.Text = dr["ToCode"].ToString();
                        ScriptManager.RegisterStartupScript(this, GetType(), "openModal", "showEditModal();", true);
                    }
                }
            }
            else if (e.CommandName == "DeleteMapping")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                try
                {
                    using (SqlConnection conn = new SqlConnection(connString))
                    {
                        string query = "DELETE FROM TMappingPadanan WHERE id = @Id";
                        SqlCommand cmd = new SqlCommand(query, conn);
                        cmd.Parameters.AddWithValue("@Id", id);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        LoadData();
                        ShowAlert("Deleted", "Mapping has been removed.", "success");
                    }
                }
                catch (Exception ex)
                {
                    ShowAlert("Error", ex.Message, "error");
                }
            }
        }

        private void ShowAlert(string title, string text, string icon)
        {
            string script = $"window.showAlert('{title}', '{text}', '{icon}');";
            ClientScript.RegisterStartupScript(this.GetType(), "SweetAlert", script, true);
        }
    }
}
