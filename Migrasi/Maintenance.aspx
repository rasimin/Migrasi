<%@ Page Title="Maintenance" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Maintenance.aspx.cs" Inherits="Migrasi.Maintenance" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <div class="row mt-4">
            <div class="col-12">
                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center py-3">
                        <h4 class="mb-0">Maintenance Generate</h4>
                        <button type="button" class="btn btn-primary btn-sm shadow-sm" onclick="resetAndShow()">
                            Add New Config
                        </button>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <asp:GridView ID="gvMaintenance" runat="server" CssClass="table table-hover table-striped mb-0" 
                                AutoGenerateColumns="False" DataKeyNames="ID" OnRowDeleting="gvMaintenance_RowDeleting" 
                                OnRowEditing="gvMaintenance_RowEditing" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="True" ItemStyle-CssClass="px-3" HeaderStyle-CssClass="px-3" />
                                    <asp:BoundField DataField="FileGenerate" HeaderText="File Name" />
                                    <asp:BoundField DataField="NamaSPGenerate" HeaderText="SP Generate" />
                                    <asp:BoundField DataField="NamaSPUpload" HeaderText="SP Upload" />
                                    <asp:BoundField DataField="CreatedAt" HeaderText="Created At" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn btn-warning btn-sm me-1">Edit</asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-danger btn-sm" OnClientClick="return confirm('Delete this record?');">Delete</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <HeaderStyle CssClass="table-dark" />
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal -->
        <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title" id="addModalLabel">Add New Configuration</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <asp:HiddenField ID="hfID" runat="server" Value="0" />
                        <div class="mb-3">
                            <label class="form-label fw-bold">File Name</label>
                            <asp:TextBox ID="txtFileName" runat="server" CssClass="form-control" placeholder="example: output.txt"></asp:TextBox>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Stored Procedure (Generate)</label>
                            <asp:TextBox ID="txtSPName" runat="server" CssClass="form-control" placeholder="example: usp_GetData"></asp:TextBox>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Stored Procedure (Upload)</label>
                            <asp:TextBox ID="txtSPUpload" runat="server" CssClass="form-control" placeholder="example: usp_SaveData"></asp:TextBox>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script type="text/javascript">
        function resetAndShow() {
            document.getElementById('<%= hfID.ClientID %>').value = "0";
            document.getElementById('<%= txtFileName.ClientID %>').value = "";
            document.getElementById('<%= txtSPName.ClientID %>').value = "";
            document.getElementById('<%= txtSPUpload.ClientID %>').value = "";
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
