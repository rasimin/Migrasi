<%@ Page Title="Maintenance" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Maintenance.aspx.cs" Inherits="Migrasi.Maintenance" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <div class="row mt-4">
            <div class="col-12">
                <div class="card card-modern shadow-lg border-0">
                    <div class="card-header border-0 py-4 px-4 d-flex justify-content-between align-items-center" style="background-color: var(--bg-header);">
                        <div>
                            <h4 class="mb-1 fw-bold text-dark">Data Configuration</h4>
                            <p class="text-secondary small mb-0">Manage your file mappings and stored procedures</p>
                        </div>
                        <button type="button" class="btn btn-primary btn-modern shadow-sm" onclick="resetAndShow()">
                            <i class="bi bi-plus-lg me-2 text-white"></i>New Config
                        </button>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <asp:GridView ID="gvMaintenance" runat="server" CssClass="table table-hover table-modern mb-0" 
                                AutoGenerateColumns="False" DataKeyNames="ID" OnRowDeleting="gvMaintenance_RowDeleting" 
                                OnRowEditing="gvMaintenance_RowEditing" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="True" ItemStyle-CssClass="text-secondary small" />
                                    <asp:BoundField DataField="FileGenerate" HeaderText="File Name" ItemStyle-CssClass="fw-500" />
                                    <asp:BoundField DataField="GenerateType" HeaderText="Type" ItemStyle-CssClass="small text-muted" />
                                    <asp:BoundField DataField="NamaSPGenerate" HeaderText="SP / Query Generate" ItemStyle-CssClass="font-monospace text-primary small sql-column" />
                                    <asp:BoundField DataField="NamaSPUpload" HeaderText="SP Upload" ItemStyle-CssClass="font-monospace text-info small" />
                                    <asp:BoundField DataField="TargetDB" HeaderText="Target DB" ItemStyle-CssClass="fw-bold text-warning small" NullDisplayText="<i class='text-muted'>(Default DB)</i>" HtmlEncode="False" />
                                    <asp:BoundField DataField="CreatedAt" HeaderText="Created At" DataFormatString="{0:yyyy-MM-dd}" ItemStyle-CssClass="text-secondary small" />
                                    <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn btn-light btn-sm text-warning me-1" ToolTip="Edit Configuration"><i class="bi bi-pencil-square"></i></asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-light btn-sm text-danger" OnClientClick="return confirmDelete(this, 'Delete this configuration?');" ToolTip="Delete Configuration"><i class="bi bi-trash"></i></asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- SQL Script Reference Alert -->
        <div class="alert alert-info border-info border-start border-4 shadow-sm mt-4 mb-4" role="alert">
            <div class="d-flex align-items-center mb-2">
                <i class="bi bi-info-circle-fill fs-5 me-2"></i>
                <h6 class="mb-0 fw-bold">Required SQL Table Setup</h6>
            </div>
            <p class="mb-2 small">Ensure these tables exist in your <strong>SimulasiDB</strong> database for proper operation:</p>
            
            <div class="row">
                <div class="col-md-6">
                    <div class="text-secondary small mb-1 fw-bold">1. Configuration Table</div>
                    <div class="bg-dark text-success p-3 rounded font-monospace" style="white-space: pre; font-size: 0.7rem; line-height: 1.2;">CREATE TABLE T_MaintenanceGenerate (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    FileGenerate VARCHAR(500) NOT NULL,
    GenerateType VARCHAR(50) DEFAULT 'SP',
    NamaSPGenerate VARCHAR(MAX) NOT NULL,
    NamaSPUpload VARCHAR(255) NULL,
    TargetDB VARCHAR(255) NULL
);</div>
                </div>
                <div class="col-md-6">
                    <div class="text-secondary small mb-1 fw-bold">2. Upload Log Table</div>
                    <div class="bg-dark text-info p-3 rounded font-monospace" style="white-space: pre; font-size: 0.7rem; line-height: 1.2;">CREATE TABLE T_UploadLog (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    ConfigID INT,
    FileName VARCHAR(500),
    RawData VARCHAR(MAX),
    Status VARCHAR(20),
    ErrorMessage VARCHAR(MAX),
    ScriptExecuted VARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE()
);</div>
                </div>
            </div>
        </div>

        <!-- Modal -->
        <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0 shadow-lg" style="border-radius: 20px;">
                    <div class="modal-header border-0 pt-4 px-4">
                        <h5 class="modal-title fw-bold text-dark" id="addModalLabel">Configuration Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body px-4 pb-4">
                        <asp:HiddenField ID="hfID" runat="server" Value="0" />
                        <div class="mb-3">
                            <label class="form-label text-secondary small fw-bold">FILE NAME</label>
                            <asp:TextBox ID="txtFileName" runat="server" CssClass="form-control form-control-lg fs-6 w-100" placeholder="e.g., product_data.txt"></asp:TextBox>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-secondary small fw-bold">GENERATE TYPE</label>
                            <asp:DropDownList ID="ddlGenerateType" runat="server" CssClass="form-select form-select-lg fs-6 w-100">
                                <asp:ListItem Text="Stored Procedure" Value="SP"></asp:ListItem>
                                <asp:ListItem Text="Plain SQL Query" Value="Plain SQL"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-secondary small fw-bold">SP / QUERY GENERATE (READ)</label>
                            <asp:TextBox ID="txtSPName" runat="server" TextMode="MultiLine" Rows="8" CssClass="form-control form-control-lg fs-6 font-monospace w-100" placeholder="usp_GetProducts ATAU SELECT * FROM..."></asp:TextBox>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-secondary small fw-bold">SP UPLOAD (WRITE)</label>
                            <asp:TextBox ID="txtSPUpload" runat="server" CssClass="form-control form-control-lg fs-6 font-monospace w-100" placeholder="usp_InsertProduct"></asp:TextBox>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-secondary small fw-bold">TARGET DATABASE (Optional)</label>
                            <asp:DropDownList ID="ddlTargetDB" runat="server" CssClass="form-select form-select-lg fs-6 w-100">
                            </asp:DropDownList>
                            <div class="form-text small text-muted mt-1">If left empty, the system will use the default database in Connection String.</div>
                        </div>
                    </div>
                    <div class="modal-footer border-0 px-4 pb-4">
                        <button type="button" class="btn btn-light btn-modern text-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnSave" runat="server" Text="Save Configuration" CssClass="btn btn-primary btn-modern" OnClick="btnSave_Click" />
                    </div>
                </div>
            </div>
        </div>

        </div>
    </main>

    <style>
        .sql-column {
            max-width: 250px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* Force inputs to fill modal width */
        #addModal .form-control, 
        #addModal .form-select {
            width: 100% !important;
            max-width: 100% !important;
        }
    </style>

    <script type="text/javascript">
        function resetAndShow() {
            document.getElementById('<%= hfID.ClientID %>').value = "0";
            document.getElementById('<%= txtFileName.ClientID %>').value = "";
            document.getElementById('<%= ddlGenerateType.ClientID %>').value = "SP";
            document.getElementById('<%= txtSPName.ClientID %>').value = "";
            document.getElementById('<%= txtSPUpload.ClientID %>').value = "";
            document.getElementById('<%= ddlTargetDB.ClientID %>').value = "";
            document.getElementById('addModalLabel').innerText = "Add New Configuration";
            showModal();
        }

        function showModal() {
            var modalEl = document.getElementById('addModal');
            if (window.bootstrap) {
                var myModal = bootstrap.Modal.getOrCreateInstance(modalEl);
                myModal.show();
            } else {
                console.error("Bootstrap is not loaded yet");
            }
        }
    </script>
</asp:Content>
