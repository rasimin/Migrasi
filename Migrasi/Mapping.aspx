<%@ Page Title="Mapping Padanan" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Mapping.aspx.cs" Inherits="Migrasi.Mapping" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <div class="row mt-4">
            <div class="col-12">
                <div class="card card-modern shadow-lg border-0">
                    <div class="card-header border-0 py-4 px-4 d-flex justify-content-between align-items-center" style="background-color: var(--bg-header);">
                        <div>
                            <h4 class="mb-1 fw-bold text-dark">Mapping Padanan</h4>
                            <p class="text-secondary small mb-0">Manage code transformations and data mapping</p>
                        </div>
                        <button type="button" class="btn btn-primary btn-modern shadow-sm px-4" onclick="showAddModal()">
                            <i class="bi bi-plus-lg me-2"></i>Add New Mapping
                        </button>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <asp:GridView ID="gvMapping" runat="server" AutoGenerateColumns="False" 
                                CssClass="table table-hover table-modern mb-0" GridLines="None" 
                                OnRowCommand="gvMapping_RowCommand" DataKeyNames="id">
                                <Columns>
                                    <asp:BoundField DataField="id" HeaderText="ID" ItemStyle-CssClass="fw-bold text-secondary" />
                                    <asp:TemplateField HeaderText="MAPPING KEY">
                                        <ItemTemplate>
                                            <span class="badge bg-light text-primary fw-bold px-2 py-1"><%# Eval("MappingKey") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="FromCode" HeaderText="FROM CODE" />
                                    <asp:BoundField DataField="ToCode" HeaderText="TO CODE" />
                                    <asp:TemplateField HeaderText="ACTIONS" ItemStyle-CssClass="text-end" HeaderStyle-CssClass="text-end">
                                        <ItemTemplate>
                                            <div class="btn-group shadow-sm rounded-3 overflow-hidden">
                                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditMapping" CommandArgument='<%# Eval("id") %>' CssClass="btn btn-light btn-sm px-2 border-0" ToolTip="Edit">
                                                    <i class="bi bi-pencil-square text-warning"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDelete" runat="server" OnClientClick='<%# "return confirmDelete(this, \"Are you sure you want to delete mapping for " + Eval("FromCode") + "?\");" %>' 
                                                    CommandName="DeleteMapping" CommandArgument='<%# Eval("id") %>' CssClass="btn btn-light btn-sm px-2 border-0" ToolTip="Delete">
                                                    <i class="bi bi-trash3 text-danger"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="text-center py-5">
                                        <i class="bi bi-folder2-open display-1 text-light"></i>
                                        <p class="text-secondary mt-3">No mapping records found.</p>
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
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
            <div class="d-flex justify-content-between align-items-center mb-1">
                <p class="mb-0 small">Before using this feature, please ensure this table exists in your <strong>SimulasiDB</strong> database:</p>
                <button type="button" class="btn btn-sm btn-outline-info border-0" onclick="copyToClipboard('sqlSetupMapping')">
                    <i class="bi bi-copy me-1"></i> Copy Script
                </button>
            </div>
            <div id="sqlSetupMapping" class="bg-dark text-success p-3 rounded font-monospace small" style="white-space: pre;">CREATE TABLE TMappingPadanan (
    id INT IDENTITY(1,1) PRIMARY KEY,
    MappingKey VARCHAR(255) NOT NULL,
    FromCode VARCHAR(255) NOT NULL,
    ToCode VARCHAR(255) NOT NULL
);</div>
        </div>
    </div>

    <!-- Modal Add/Edit -->
    <div class="modal fade" id="mappingModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                <div class="modal-header border-0 py-3 px-4" style="background-color: var(--primary-blue);">
                    <h5 class="modal-title text-white fw-bold"><i class="bi bi-intersect me-2"></i><span id="modalTitle">Add New Mapping</span></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4" style="background-color: var(--bg-card);">
                    <asp:HiddenField ID="hfMappingId" runat="server" />
                    <div class="mb-3">
                        <label class="form-label text-secondary small fw-bold">MAPPING KEY</label>
                        <asp:TextBox ID="txtMappingKey" runat="server" CssClass="form-control form-control-lg fs-6" placeholder="e.g. PRODUCT_CATEGORY"></asp:TextBox>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-secondary small fw-bold">FROM CODE</label>
                            <asp:TextBox ID="txtFromCode" runat="server" CssClass="form-control form-control-lg fs-6" placeholder="Old Code"></asp:TextBox>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-secondary small fw-bold">TO CODE</label>
                            <asp:TextBox ID="txtToCode" runat="server" CssClass="form-control form-control-lg fs-6" placeholder="New Code"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 p-4 pt-0" style="background-color: var(--bg-card);">
                    <button type="button" class="btn btn-light btn-modern px-4" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSave" runat="server" Text="Save Mapping" CssClass="btn btn-primary btn-modern px-4 shadow-sm" OnClick="btnSave_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function showAddModal() {
            document.getElementById('modalTitle').innerText = 'Add New Mapping';
            document.getElementById('<%= hfMappingId.ClientID %>').value = '';
            document.getElementById('<%= txtMappingKey.ClientID %>').value = '';
            document.getElementById('<%= txtFromCode.ClientID %>').value = '';
            document.getElementById('<%= txtToCode.ClientID %>').value = '';
            new bootstrap.Modal(document.getElementById('mappingModal')).show();
        }

        function showEditModal() {
            document.getElementById('modalTitle').innerText = 'Edit Mapping';
            new bootstrap.Modal(document.getElementById('mappingModal')).show();
        }
    </script>
</asp:Content>
