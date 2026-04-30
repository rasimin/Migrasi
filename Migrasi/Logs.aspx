<%@ Page Title="Upload Logs" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Logs.aspx.cs" Inherits="Migrasi.Logs" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <div class="row mt-4">
            <div class="col-12">
                <div class="card card-modern shadow-lg border-0">
                    <div class="card-header border-0 py-3 px-4" style="background-color: var(--bg-header);">
                        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                            <div>
                                <h4 class="mb-1 fw-bold text-dark"><i class="bi bi-journal-text me-2 text-primary"></i>Upload Activity Logs</h4>
                                <p class="text-secondary small mb-0">Monitor row-level upload status and error details</p>
                            </div>
                            <div class="d-flex flex-wrap gap-2 align-items-center justify-content-md-end">
                                <div class="d-flex flex-column">
                                    <label class="x-small fw-bold text-uppercase text-muted mb-1 ms-2" style="font-size: 0.65rem;">Date Range</label>
                                    <div class="d-flex align-items-center gap-1 border rounded-pill bg-white px-2 py-0">
                                        <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control form-control-sm border-0 shadow-none bg-transparent" TextMode="Date" style="width: 125px; font-size: 0.8rem;"></asp:TextBox>
                                        <span class="text-muted small">-</span>
                                        <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control form-control-sm border-0 shadow-none bg-transparent" TextMode="Date" style="width: 125px; font-size: 0.8rem;"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="d-flex flex-column">
                                    <label class="x-small fw-bold text-uppercase text-muted mb-1 ms-2" style="font-size: 0.65rem;">Search Keywords</label>
                                    <div class="input-group input-group-sm border rounded-pill overflow-hidden bg-white px-2 py-0" style="width: 220px;">
                                        <span class="input-group-text bg-transparent border-0 pe-1"><i class="bi bi-search text-muted small"></i></span>
                                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-0 shadow-none bg-transparent" placeholder="File, script, raw..." style="font-size: 0.85rem;"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="d-flex flex-column">
                                    <label class="x-small fw-bold text-uppercase text-muted mb-1 ms-2" style="font-size: 0.65rem;">Status</label>
                                    <div class="border rounded-pill bg-white px-2 py-0">
                                        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select form-select-sm border-0 shadow-none bg-transparent fw-bold text-secondary" style="width: 110px; font-size: 0.8rem;">
                                            <asp:ListItem Text="All Status" Value=""></asp:ListItem>
                                            <asp:ListItem Text="Success" Value="SUCCESS"></asp:ListItem>
                                            <asp:ListItem Text="Failed" Value="FAILED"></asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="d-flex align-items-end pt-3">
                                    <div class="btn-group shadow-sm rounded-pill overflow-hidden border">
                                        <asp:LinkButton ID="btnFilter" runat="server" CssClass="btn btn-primary btn-sm px-3 border-0" OnClick="btnFilter_Click">
                                            <i class="bi bi-funnel-fill me-1"></i>Apply
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnClearLogs" runat="server" CssClass="btn btn-white btn-sm text-danger border-0 border-start" OnClick="btnClearLogs_Click" OnClientClick="return confirm('Delete ALL logs?');">
                                            <i class="bi bi-trash"></i>
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <asp:GridView ID="gvLogs" runat="server" CssClass="table table-hover table-modern mb-0" 
                                AutoGenerateColumns="False" GridLines="None" AllowPaging="True" PageSize="20" OnPageIndexChanging="gvLogs_PageIndexChanging">
                                <Columns>
                                    <asp:TemplateField HeaderText="Action">
                                        <ItemTemplate>
                                            <button type="button" class="btn btn-light btn-sm text-primary fw-bold px-3 shadow-sm border" 
                                                onclick="showFullRowDetail(this)"
                                                data-id='<%# Eval("ID") %>'
                                                data-date='<%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm:ss}") %>'
                                                data-filename='<%# Eval("FileName") %>'
                                                data-script='<%# HttpUtility.HtmlAttributeEncode(Eval("ScriptExecuted").ToString()) %>'
                                                data-status='<%# Eval("Status") %>'
                                                data-raw='<%# HttpUtility.HtmlAttributeEncode(Eval("RawData").ToString()) %>'
                                                data-error='<%# HttpUtility.HtmlAttributeEncode(Eval("ErrorMessage").ToString()) %>'>
                                                <i class="bi bi-eye me-1"></i>View
                                            </button>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="ID" HeaderText="ID" ItemStyle-CssClass="text-secondary small" />
                                    <asp:BoundField DataField="CreatedAt" HeaderText="Date Time" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" ItemStyle-CssClass="small" />
                                    <asp:BoundField DataField="FileName" HeaderText="File Name" ItemStyle-CssClass="fw-bold small" />
                                    <asp:TemplateField HeaderText="Script Executed">
                                        <ItemTemplate>
                                            <div class="text-info small font-monospace text-truncate" style="max-width: 300px;" title='<%# Eval("ScriptExecuted") %>'>
                                                <%# Eval("ScriptExecuted") %>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <span class='<%# Eval("Status").ToString() == "SUCCESS" ? "badge bg-success-subtle text-success border border-success" : "badge bg-danger-subtle text-danger border border-danger" %> px-2 py-1 small fw-bold'>
                                                <%# Eval("Status") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Raw Data Content">
                                        <ItemTemplate>
                                            <div class="font-monospace small text-muted text-truncate" style="max-width: 300px;">
                                                <%# Eval("RawData") %>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Error Message">
                                        <ItemTemplate>
                                            <div class="small text-danger text-truncate" style="max-width: 300px;">
                                                <%# Eval("ErrorMessage") %>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <PagerStyle CssClass="pagination-container p-3 border-top" />
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
    </main>

    <!-- Detail Modal -->
    <div class="modal fade" id="detailModal" tabindex="-1" aria-labelledby="detailModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content shadow-lg border-0 rounded-4">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" id="detailModalLabel"><i class="bi bi-info-circle me-2 text-primary"></i>Log Detail</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <div class="p-3 bg-light rounded-3">
                                <label class="text-secondary small fw-bold text-uppercase mb-1">Log Info</label>
                                <div class="row">
                                    <div class="col-md-3"><strong>ID:</strong> <span id="det-id"></span></div>
                                    <div class="col-md-5"><strong>Date:</strong> <span id="det-date"></span></div>
                                    <div class="col-md-4 text-end"><strong>Status:</strong> <span id="det-status"></span></div>
                                </div>
                                <div class="mt-2"><strong>File:</strong> <span id="det-filename" class="text-truncate d-inline-block align-bottom" style="max-width: 80%;"></span></div>
                                <div class="mt-2 text-danger small"><strong>Error:</strong> <span id="det-error-container"></span></div>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="p-3 bg-light rounded-3">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <label class="text-secondary small fw-bold text-uppercase mb-0">Executed SQL Command</label>
                                    <button type="button" class="btn btn-outline-info btn-sm py-0 px-2" onclick="copyText('det-script')">
                                        <i class="bi bi-copy me-1"></i>Copy SQL
                                    </button>
                                </div>
                                <div id="det-script" class="font-monospace small p-3 bg-dark text-info rounded border" style="white-space: pre-wrap; word-break: break-all; max-height: 200px; overflow-y: auto;">
                                </div>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="p-3 bg-light rounded-3">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <label class="text-secondary small fw-bold text-uppercase mb-0">Raw Data Content</label>
                                    <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" onclick="copyText('det-raw')">
                                        <i class="bi bi-copy me-1"></i>Copy Raw
                                    </button>
                                </div>
                                <div id="det-raw" class="font-monospace small p-3 bg-white rounded border" style="white-space: pre-wrap; word-break: break-all; max-height: 200px; overflow-y: auto; color: var(--text-main);">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary btn-modern shadow-sm" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function showFullRowDetail(btn) {
            const id = btn.getAttribute('data-id');
            const date = btn.getAttribute('data-date');
            const filename = btn.getAttribute('data-filename');
            const script = btn.getAttribute('data-script');
            const status = btn.getAttribute('data-status');
            const raw = btn.getAttribute('data-raw');
            const error = btn.getAttribute('data-error');

            document.getElementById('det-id').innerText = id;
            document.getElementById('det-date').innerText = date;
            document.getElementById('det-filename').innerText = filename || '-';
            document.getElementById('det-filename').title = filename || '-';
            document.getElementById('det-script').innerText = script || '-';
            document.getElementById('det-raw').innerText = raw;
            document.getElementById('det-error-container').innerText = error || 'No error details recorded.';
            
            const statusBadge = status === 'SUCCESS' 
                ? '<span class="badge bg-success-subtle text-success border border-success px-2">SUCCESS</span>' 
                : '<span class="badge bg-danger-subtle text-danger border border-danger px-2">FAILED</span>';
            document.getElementById('det-status').innerHTML = statusBadge;

            const myModal = new bootstrap.Modal(document.getElementById('detailModal'));
            myModal.show();
        }

        function copyText(elementId) {
            const content = document.getElementById(elementId).innerText;
            navigator.clipboard.writeText(content).then(() => {
                const btn = event.currentTarget;
                const originalHtml = btn.innerHTML;
                btn.innerHTML = '<i class="bi bi-check2 me-1"></i>Copied';
                const originalClass = btn.classList.contains('btn-outline-primary') ? 'btn-outline-primary' : 'btn-outline-info';
                btn.classList.replace(originalClass, 'btn-success');
                btn.classList.add('text-white');
                
                setTimeout(() => {
                    btn.innerHTML = originalHtml;
                    btn.classList.replace('btn-success', originalClass);
                    btn.classList.remove('text-white');
                }, 2000);
            });
        }
    </script>

    <style>
        .bg-success-subtle { background-color: rgba(25, 135, 84, 0.1) !important; }
        .bg-danger-subtle { background-color: rgba(220, 53, 69, 0.1) !important; }
        .pagination-container table { margin: 0 auto; }
        .pagination-container td { padding: 0 5px; }
        .pagination-container a, .pagination-container span {
            padding: 5px 12px;
            border-radius: 6px;
            border: 1px solid var(--border-color);
            text-decoration: none;
            color: var(--text-main);
        }
        .pagination-container span { background: var(--primary-blue); color: white; border-color: var(--primary-blue); }
        
        /* Modal Styles for Dark Mode */
        [data-bs-theme="dark"] .bg-light {
            background-color: #1e293b !important;
        }
    </style>
</asp:Content>
