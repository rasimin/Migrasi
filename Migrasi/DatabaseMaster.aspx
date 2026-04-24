<%@ Page Title="Database Master" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="DatabaseMaster.aspx.cs" Inherits="Migrasi.DatabaseMaster" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid py-4">
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-end">
                    <div>
                        <h3 class="fw-bold text-dark mb-1"><i class="bi bi-server me-2 text-primary"></i>Database Master</h3>
                        <p class="text-secondary mb-0">Manage registered databases for migration queries and sync from SQL Server.</p>
                    </div>
                    <div class="d-flex gap-2">
                        <asp:LinkButton ID="btnSync" runat="server" CssClass="btn btn-warning shadow-sm" OnClick="btnSync_Click" OnClientClick="showLoading('Syncing Databases...', 'Fetching live data from sys.databases', true);">
                            <i class="bi bi-arrow-repeat me-1"></i> Sync from Server
                        </asp:LinkButton>
                        <button type="button" class="btn btn-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#addModal">
                            <i class="bi bi-plus-lg me-1"></i> Add Database
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="card card-modern shadow-lg border-0">
            <div class="card-body p-0">
                <asp:GridView ID="gvDatabases" runat="server" AutoGenerateColumns="False" DataKeyNames="ID"
                    CssClass="table table-hover table-modern mb-0" GridLines="None"
                    OnRowEditing="gvDatabases_RowEditing" OnRowCancelingEdit="gvDatabases_RowCancelingEdit"
                    OnRowUpdating="gvDatabases_RowUpdating" OnRowDeleting="gvDatabases_RowDeleting">
                    <Columns>
                        <asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="True" ItemStyle-Width="80px" ItemStyle-CssClass="fw-bold text-secondary" />
                        
                        <asp:TemplateField HeaderText="Database Name">
                            <ItemTemplate>
                                <div class="d-flex align-items-center">
                                    <div class="bg-light rounded-circle p-2 me-3 text-primary d-flex align-items-center justify-content-center" style="width: 35px; height: 35px;">
                                        <i class="bi bi-database"></i>
                                    </div>
                                    <span class="fw-bold"><%# Eval("DBName") %></span>
                                </div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtDBName" runat="server" Text='<%# Bind("DBName") %>' CssClass="form-control form-control-sm"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Description">
                            <ItemTemplate>
                                <span class="text-secondary"><%# Eval("Description") %></span>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtDescription" runat="server" Text='<%# Bind("Description") %>' CssClass="form-control form-control-sm"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "<span class='badge bg-success'>Active</span>" : "<span class='badge bg-danger'>Inactive</span>" %>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:CheckBox ID="chkIsActive" runat="server" Checked='<%# Bind("IsActive") %>' />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:CommandField ShowEditButton="True" ShowDeleteButton="True" 
                            ControlStyle-CssClass="btn btn-sm btn-light border shadow-sm mx-1" 
                            EditText="<i class='bi bi-pencil'></i>" 
                            DeleteText="<i class='bi bi-trash text-danger'></i>" 
                            UpdateText="<i class='bi bi-check-lg text-success'></i>" 
                            CancelText="<i class='bi bi-x-lg text-secondary'></i>" />
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="text-center py-5">
                            <i class="bi bi-inbox text-muted" style="font-size: 3rem;"></i>
                            <h5 class="mt-3 text-secondary">No databases recorded.</h5>
                            <p class="text-muted small">Click 'Sync from Server' or 'Add Database' to begin.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
        </div>

        <!-- SQL Script Reference Alert -->
        <div class="alert alert-info border-info border-start border-4 shadow-sm mt-4 mb-4" role="alert">
            <div class="d-flex align-items-center mb-2">
                <i class="bi bi-info-circle-fill fs-5 me-2"></i>
                <h6 class="mb-0 fw-bold">Required SQL Table Setup</h6>
            </div>
            <p class="mb-2 small">Before using this feature, please run this query in your <strong>SimulasiDB</strong> database:</p>
            <div class="bg-dark text-success p-3 rounded font-monospace small" style="white-space: pre;">CREATE TABLE TDatabaseMaster (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    DBName VARCHAR(255) NOT NULL UNIQUE,
    Description VARCHAR(500) NULL,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);</div>
        </div>
    </div>

    <!-- Modal Add -->
    <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <div class="modal-header border-bottom-0 pb-0">
                    <h5 class="modal-title fw-bold" id="addModalLabel">Add New Database</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-bold">Database Name <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtNewDBName" runat="server" CssClass="form-control border-2 shadow-sm"></asp:TextBox>
                    </div>
                    <div class="mb-4">
                        <label class="form-label text-secondary small fw-bold">Description</label>
                        <asp:TextBox ID="txtNewDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control border-2 shadow-sm"></asp:TextBox>
                    </div>
                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnSave" runat="server" Text="Save Database" CssClass="btn btn-primary px-4" OnClick="btnSave_Click" OnClientClick="showLoading('Saving...', 'Adding database record');" />
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
