<%@ Page Title="Connection Manager" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Connections.aspx.cs" Inherits="Migrasi.Connections" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid py-4">
        <div class="row">
            <div class="col-12">
                <div class="card card-modern shadow-lg border-0 mb-4">
                    <div class="card-header border-0 py-4 px-4 d-flex justify-content-between align-items-center" style="background-color: var(--bg-header);">
                        <div>
                            <h4 class="mb-1 fw-bold text-dark"><i class="bi bi-gear-fill me-2 text-primary"></i>Connection Manager</h4>
                            <p class="text-secondary small mb-0">Manage multiple database connection profiles</p>
                        </div>
                        <button type="button" class="btn btn-primary btn-modern shadow-sm" onclick="showAddModal()">
                            <i class="bi bi-plus-lg me-1"></i> Add New Profile
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card card-modern shadow-lg border-0">
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <asp:GridView ID="gvProfiles" runat="server" AutoGenerateColumns="False" 
                                CssClass="table table-hover table-modern mb-0" GridLines="None"
                                OnRowCommand="gvProfiles_RowCommand">
                                <Columns>
                                    <asp:TemplateField HeaderText="Status" ItemStyle-Width="100px">
                                        <ItemTemplate>
                                            <span class='<%# (bool)Eval("IsActive") ? "badge bg-success shadow-sm" : "badge bg-light text-muted border" %> px-3 py-2'>
                                                <%# (bool)Eval("IsActive") ? "<i class='bi bi-check-circle-fill me-1'></i> Active" : "Inactive" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="Name" HeaderText="Profile Name" ItemStyle-CssClass="fw-bold text-dark" />
                                    <asp:BoundField DataField="Server" HeaderText="Server / Instance" />
                                    <asp:BoundField DataField="Database" HeaderText="Default DB" />
                                    <asp:BoundField DataField="Username" HeaderText="User" />
                                    <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-end px-4" HeaderStyle-CssClass="text-end px-4">
                                        <ItemTemplate>
                                            <div class="d-flex justify-content-end gap-2">
                                                <asp:LinkButton ID="btnActivate" runat="server" CommandName="Activate" CommandArgument='<%# Eval("Id") %>' 
                                                    CssClass="btn btn-light btn-sm text-primary shadow-sm" Visible='<%# !(bool)Eval("IsActive") %>'
                                                    ToolTip="Activate this connection">
                                                    <i class="bi bi-lightning-fill"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditProfile" CommandArgument='<%# Eval("Id") %>' 
                                                    CssClass="btn btn-light btn-sm text-warning shadow-sm" ToolTip="Edit Profile">
                                                    <i class="bi bi-pencil-square"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteProfile" CommandArgument='<%# Eval("Id") %>' 
                                                    CssClass="btn btn-light btn-sm text-danger shadow-sm" 
                                                    OnClientClick="return confirm('Are you sure you want to delete this profile?');"
                                                    ToolTip="Delete Profile">
                                                    <i class="bi bi-trash"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="text-center py-5">
                                        <i class="bi bi-database-exclamation fs-1 text-muted opacity-25"></i>
                                        <p class="mt-3 text-secondary">No connection profiles found. Add one to get started.</p>
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add/Edit Modal -->
    <div class="modal fade" id="profileModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" id="modalTitle" runat="server">Add Connection Profile</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <asp:HiddenField ID="hfProfileId" runat="server" />
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-secondary">PROFILE NAME</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="e.g. Production Server"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-secondary">SERVER / INSTANCE</label>
                        <asp:TextBox ID="txtServer" runat="server" CssClass="form-control" placeholder="e.g. 192.168.1.10 or localhost\SQLEXPRESS"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-secondary">DEFAULT DATABASE</label>
                        <asp:TextBox ID="txtDatabase" runat="server" CssClass="form-control" placeholder="e.g. SimulasiDB"></asp:TextBox>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label small fw-bold text-secondary">USERNAME</label>
                            <asp:TextBox ID="txtUser" runat="server" CssClass="form-control" placeholder="sa"></asp:TextBox>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label small fw-bold text-secondary">PASSWORD</label>
                            <asp:TextBox ID="txtPass" runat="server" CssClass="form-control" TextMode="Password" placeholder="******"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSave" runat="server" Text="Save Profile" CssClass="btn btn-primary px-4" OnClick="btnSave_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function showAddModal() {
            document.getElementById('<%= modalTitle.ClientID %>').innerText = "Add Connection Profile";
            document.getElementById('<%= hfProfileId.ClientID %>').value = "";
            document.getElementById('<%= txtName.ClientID %>').value = "";
            document.getElementById('<%= txtServer.ClientID %>').value = "";
            document.getElementById('<%= txtDatabase.ClientID %>').value = "";
            document.getElementById('<%= txtUser.ClientID %>').value = "";
            document.getElementById('<%= txtPass.ClientID %>').value = "";
            
            var modal = new bootstrap.Modal(document.getElementById('profileModal'));
            modal.show();
        }

        function showEditModal(name, server, db, user) {
            document.getElementById('modalTitle').innerText = "Edit Connection Profile";
            document.getElementById('<%= txtName.ClientID %>').value = name;
            document.getElementById('<%= txtServer.ClientID %>').value = server;
            document.getElementById('<%= txtDatabase.ClientID %>').value = db;
            document.getElementById('<%= txtUser.ClientID %>').value = user;
            document.getElementById('<%= txtPass.ClientID %>').value = ""; // Don't show password for security
            
            var modal = new bootstrap.Modal(document.getElementById('profileModal'));
            modal.show();
        }
    </script>
</asp:Content>
