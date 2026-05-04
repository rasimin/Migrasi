using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Migrasi
{
    public partial class Connections : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindProfiles();
            }
        }

        private void BindProfiles()
        {
            gvProfiles.DataSource = ConnectionHelper.GetProfiles();
            gvProfiles.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            var profiles = ConnectionHelper.GetProfiles();
            string id = hfProfileId.Value;

            if (string.IsNullOrEmpty(id))
            {
                // Add New
                profiles.Add(new ConnectionProfile
                {
                    Id = Guid.NewGuid().ToString(),
                    Name = txtName.Text.Trim(),
                    Server = txtServer.Text.Trim(),
                    Database = txtDatabase.Text.Trim(),
                    Username = txtUser.Text.Trim(),
                    Password = txtPass.Text.Trim(),
                    IsActive = profiles.Count == 0 // First profile is active by default
                });
            }
            else
            {
                // Update
                var profile = profiles.FirstOrDefault(p => p.Id == id);
                if (profile != null)
                {
                    profile.Name = txtName.Text.Trim();
                    profile.Server = txtServer.Text.Trim();
                    profile.Database = txtDatabase.Text.Trim();
                    profile.Username = txtUser.Text.Trim();
                    if (!string.IsNullOrEmpty(txtPass.Text))
                        profile.Password = txtPass.Text.Trim();
                }
            }

            ConnectionHelper.SaveProfiles(profiles);
            BindProfiles();
        }

        protected void gvProfiles_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument.ToString();
            var profiles = ConnectionHelper.GetProfiles();

            if (e.CommandName == "Activate")
            {
                profiles.ForEach(p => p.IsActive = (p.Id == id));
                ConnectionHelper.SaveProfiles(profiles);
                BindProfiles();
            }
            else if (e.CommandName == "EditProfile")
            {
                var profile = profiles.FirstOrDefault(p => p.Id == id);
                if (profile != null)
                {
                    hfProfileId.Value = profile.Id;
                    txtName.Text = profile.Name;
                    txtServer.Text = profile.Server;
                    txtDatabase.Text = profile.Database;
                    txtUser.Text = profile.Username;
                    // Password left empty for security, only update if user types new one
                    
                    ScriptManager.RegisterStartupScript(this, GetType(), "openEdit", "var modal = new bootstrap.Modal(document.getElementById('profileModal')); modal.show();", true);
                }
            }
            else if (e.CommandName == "DeleteProfile")
            {
                var profile = profiles.FirstOrDefault(p => p.Id == id);
                if (profile != null)
                {
                    profiles.Remove(profile);
                    // If we deleted the active one, pick the first one as active
                    if (profile.IsActive && profiles.Count > 0)
                        profiles[0].IsActive = true;
                        
                    ConnectionHelper.SaveProfiles(profiles);
                    BindProfiles();
                }
            }
        }
    }
}
