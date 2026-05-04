<%@ Page Title="Object Search" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DatabaseSearch.aspx.cs" Inherits="Migrasi.DatabaseSearch" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid py-4">
        <div class="row">
            <div class="col-12">
                <div class="card card-modern shadow-lg border-0">
                    <div class="card-header border-0 py-4 px-4 d-flex justify-content-between align-items-center" style="background-color: var(--bg-header);">
                        <div>
                            <h4 class="mb-1 fw-bold text-dark"><i class="bi bi-search me-2 text-primary"></i>Database Object Search</h4>
                            <p class="text-secondary small mb-0">Search for tables or SPs containing specific text in their definition</p>
                        </div>
                        <div class="d-flex gap-2 align-items-end">
                             <div class="d-flex flex-column">
                                 <label class="small text-secondary fw-bold mb-1 ms-1" style="font-size: 0.7rem;">DATABASE</label>
                                 <div class="input-group shadow-sm" style="width: auto;">
                                     <span class="input-group-text px-2" style="background-color: var(--bg-body); border-color: var(--border-color); color: var(--text-main);">
                                         <i class="bi bi-database text-primary"></i>
                                     </span>
                                     <asp:DropDownList ID="ddlDatabase" runat="server" CssClass="form-select py-2 fw-bold" 
                                         style="min-width: 200px; background-color: var(--bg-card); border-color: var(--border-color); color: var(--text-main) !important;">
                                     </asp:DropDownList>
                                 </div>
                             </div>
                             <div class="d-flex flex-column">
                                 <label class="small text-secondary fw-bold mb-1 ms-1" style="font-size: 0.7rem;">SEARCH KEYWORD</label>
                                 <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control py-2 shadow-sm" 
                                     placeholder="Table or SP name..." style="min-width: 300px;" 
                                     onkeypress="if(event.keyCode==13){document.getElementById('btnSearch').click(); return false;}"></asp:TextBox>
                             </div>
                             <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn btn-primary btn-modern px-4 py-2 shadow-sm mb-0" 
                                 style="height: 42px; display: flex; align-items: center;"
                                 OnClick="btnSearch_Click" ClientIDMode="Static">
                                 <i class="bi bi-search me-1"></i> Search
                             </asp:LinkButton>
                        </div>
                    </div>
                    <div class="card-body px-0">
                        <div class="table-responsive">
                            <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="False" 
                                CssClass="table table-hover table-modern mb-0" GridLines="None"
                                OnRowCommand="gvResults_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="name" HeaderText="Object Name" ItemStyle-CssClass="fw-bold text-dark" />
                                    <asp:TemplateField HeaderText="Type">
                                        <ItemTemplate>
                                            <span class='<%# GetBadgeClass(Eval("xtype").ToString()) %>'>
                                                <%# GetTypeName(Eval("xtype").ToString()) %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="text-end" HeaderStyle-CssClass="text-end">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnView" runat="server" CommandName="ViewDetail" CommandArgument='<%# Eval("name") %>' CssClass="btn btn-light btn-sm text-primary">
                                                <i class="bi bi-code-slash me-1"></i> View Script
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="p-5 text-center text-secondary">
                                        <i class="bi bi-search display-4 d-block mb-3 opacity-25"></i>
                                        Enter a search term above to find database objects.
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Script Detail Modal -->
    <div class="modal fade" id="scriptModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-xl">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 20px;">
                <div class="modal-header border-0 pt-4 px-4">
                    <h5 class="modal-title fw-bold text-dark" id="modalTitle">Object Script</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body px-4 pb-4">
                    <div class="bg-dark rounded-4 mb-3" style="width: 100%; border: 1px solid rgba(255,255,255,0.1); overflow: hidden;">
                        <textarea id="txtScriptDetail" class="form-control font-monospace p-4" 
                            style="height: 600px; width: 100% !important; min-width: 100% !important; display: block !important; background: transparent; color: #22c55e; border: none; resize: none; font-size: 0.85rem; line-height: 1.6; outline: none; box-shadow: none;"></textarea>
                    </div>
                    <div class="text-end d-flex justify-content-end gap-2">
                        <button type="button" class="btn btn-info text-white btn-modern px-4" onclick="copyToQueryRunner()">
                            <i class="bi bi-terminal me-1"></i> Copy to Query Runner
                        </button>
                        <button type="button" class="btn btn-light btn-modern px-4" onclick="copyScript()">
                            <i class="bi bi-clipboard me-1"></i> Copy Script
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function showScriptModal(title, base64Script) {
            try {
                // Decode base64 to string handling UTF-8
                const script = decodeURIComponent(escape(window.atob(base64Script)));
                document.getElementById('modalTitle').innerText = 'Script: ' + title;
                document.getElementById('txtScriptDetail').value = script;
                var modal = new bootstrap.Modal(document.getElementById('scriptModal'));
                modal.show();
            } catch (e) {
                console.error('Error decoding script:', e);
                const script = window.atob(base64Script);
                document.getElementById('modalTitle').innerText = 'Script: ' + title;
                document.getElementById('txtScriptDetail').value = script;
                var modal = new bootstrap.Modal(document.getElementById('scriptModal'));
                modal.show();
            }
        }

        function copyScript() {
            const txt = document.getElementById('txtScriptDetail');
            txt.select();
            navigator.clipboard.writeText(txt.value);
            showAlert('Success', 'Script copied to clipboard!', 'success');
        }

        function copyToQueryRunner() {
            const txt = document.getElementById('txtScriptDetail');
            sessionStorage.setItem('pendingSQL', txt.value);
            window.location.href = 'Query.aspx';
        }
    </script>
</asp:Content>
