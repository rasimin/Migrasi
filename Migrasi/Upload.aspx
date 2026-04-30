<%@ Page Title="Upload Data" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Upload.aspx.cs" Inherits="Migrasi.Upload" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <div class="row mt-4">
            <div class="col-12">
                <div class="card card-modern">
                    <div class="card-header border-0 py-4 px-4" style="background-color: var(--bg-header);">
                        <h4 class="mb-1 fw-bold text-dark">Data Ingestion</h4>
                        <p class="text-secondary small mb-0">Upload and process standardized TXT files</p>
                    </div>
                    <div class="card-body px-4 pb-4">
                        <div class="row g-4 align-items-end mb-4 bg-light p-4 rounded-4 mx-0 mt-2">
                            <div class="col-md-4">
                                <label class="form-label text-secondary small fw-bold">1. CONFIGURATION</label>
                                <asp:DropDownList ID="ddlConfig" runat="server" CssClass="form-select form-select-lg fs-6" DataTextField="FileGenerate" DataValueField="NamaSPUpload">
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label text-secondary small fw-bold">2. SELECT FILE</label>
                                <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control form-control-lg fs-6" accept=".txt" />
                            </div>
                            <div class="col-md-4">
                                <asp:Button ID="btnPreview" runat="server" Text="Analyze & Preview" CssClass="btn btn-primary btn-modern w-100 shadow-sm" OnClick="btnPreview_Click" />
                            </div>
                        </div>

                        <div id="previewArea" runat="server" visible="false" class="mt-5">
                            <div class="d-flex justify-content-between align-items-center mb-4 border-start border-primary border-4 ps-3">
                                <div>
                                    <h5 class="mb-0 text-dark fw-bold">Analysis Results</h5>
                                    <p class="text-secondary small mb-0">Review the mapped data before committing to database</p>
                                </div>
                                <asp:Label ID="lblTotal" runat="server" CssClass="badge rounded-pill text-primary fw-bold px-3 py-2"></asp:Label>
                            </div>
                            
                            <div class="table-responsive rounded-3 border" style="max-height: 450px; overflow-y: auto;">
                                <asp:GridView ID="gvUploadPreview" runat="server" CssClass="table table-hover table-modern mb-0" 
                                    AutoGenerateColumns="true" GridLines="None" OnRowDataBound="gvUploadPreview_RowDataBound">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Action" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" ItemStyle-Width="100px">
                                            <ItemTemplate>
                                                <button type="button" id="btnViewDetail" runat="server" class="btn btn-light btn-sm text-primary fw-bold px-3 shadow-sm border" 
                                                    style="display:none;" onclick="showFullRowDetail(this)">
                                                    <i class="bi bi-eye me-1"></i>View
                                                </button>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" ItemStyle-Width="100px">
                                            <ItemTemplate>
                                                <asp:Literal ID="litStatus" runat="server"></asp:Literal>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>

    <!-- Log Detail Modal -->
    <div class="modal fade" id="logDetailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <div class="modal-header border-0 pb-0 px-4 pt-4">
                    <h5 class="modal-title fw-bold d-flex align-items-center">
                        <i class="bi bi-info-circle text-primary me-2"></i>Log Detail
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <!-- Status Header -->
                    <div class="alert bg-light border-0 mb-4 p-3 rounded-3 d-flex justify-content-between align-items-center">
                        <div>
                            <div class="text-muted x-small fw-bold text-uppercase mb-1">Execution Status</div>
                            <div id="modalStatusBadge"></div>
                        </div>
                        <div class="text-end">
                            <div class="text-muted x-small fw-bold text-uppercase mb-1">Target SP</div>
                            <div class="fw-bold small" id="modalSPName"></div>
                        </div>
                    </div>

                    <!-- Error Message (Optional) -->
                    <div id="modalErrorContainer" class="mb-4 d-none">
                        <label class="form-label text-danger small fw-bold"><i class="bi bi-exclamation-triangle me-1"></i>Error Message</label>
                        <div class="alert alert-danger py-2 px-3 small border-0 shadow-sm" id="modalError"></div>
                    </div>

                    <!-- SQL Command Section -->
                    <div class="mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <label class="form-label text-secondary small fw-bold text-uppercase mb-0">Executed SQL Command</label>
                            <button type="button" class="btn btn-outline-info btn-sm py-0 px-2" onclick="copyToClipboard('modalSQL', 'SQL')">
                                <i class="bi bi-clipboard me-1"></i>Copy SQL
                            </button>
                        </div>
                        <div class="bg-dark rounded-3 p-3 position-relative overflow-hidden">
                            <pre id="modalSQL" class="text-info small font-monospace mb-0" style="max-height: 250px; overflow-y: auto; white-space: pre-wrap; word-break: break-all;"></pre>
                        </div>
                    </div>

                    <!-- Raw Data Section -->
                    <div class="mb-0">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <label class="form-label text-secondary small fw-bold text-uppercase mb-0">Raw Data Content</label>
                            <button type="button" class="btn btn-outline-secondary btn-sm py-0 px-2" onclick="copyToClipboard('modalRaw', 'Data')">
                                <i class="bi bi-clipboard me-1"></i>Copy Raw
                            </button>
                        </div>
                        <div class="bg-light border rounded-3 p-3">
                            <pre id="modalRaw" class="text-dark small font-monospace mb-0" style="max-height: 150px; overflow-y: auto; white-space: pre-wrap; word-break: break-all;"></pre>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 p-4">
                    <button type="button" class="btn btn-secondary btn-modern px-4" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function showFullRowDetail(btn) {
            const data = $(btn);
            $('#modalStatusBadge').html(data.attr('data-status-badge'));
            $('#modalSPName').text(data.attr('data-sp'));
            $('#modalSQL').text(data.attr('data-script'));
            $('#modalRaw').text(data.attr('data-raw'));
            
            const error = data.attr('data-error');
            if (error && error.trim() !== "") {
                $('#modalError').text(error);
                $('#modalErrorContainer').removeClass('d-none');
            } else {
                $('#modalErrorContainer').addClass('d-none');
            }

            const modal = new bootstrap.Modal(document.getElementById('logDetailModal'));
            modal.show();
        }

        function copyToClipboard(id, label) {
            const text = document.getElementById(id).innerText;
            navigator.clipboard.writeText(text).then(() => {
                const toast = Swal.mixin({ toast: true, position: 'top-end', showConfirmButton: false, timer: 2000 });
                toast.fire({ icon: 'success', title: label + ' copied to clipboard' });
            });
        }
    </script>

                            <div class="mt-5 text-center p-4 rounded-4" style="background-color: var(--bg-body); border: 1px dashed var(--primary-blue);">
                                <p class="text-success small fw-bold mb-3"><i class="bi bi-check-circle-fill me-2"></i>Data analysis complete. Ready for ingestion.</p>
                                <asp:Button ID="btnProcessUpload" runat="server" Text="Execute Database Upload" CssClass="btn btn-success btn-modern px-5 shadow-sm" OnClick="btnProcessUpload_Click" OnClientClick="return confirmDelete(this, 'Process this data to Database?');" />
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
    CreatedAt DATETIME DEFAULT GETDATE()
);</div>
                </div>
            </div>
        </div>
    </main>
</asp:Content>
