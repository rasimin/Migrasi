<%@ Page Title="Query Runner" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Query.aspx.cs" Inherits="Migrasi.Query" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid py-4">
        <div class="row">
            <div class="col-12">
                <div class="card card-modern shadow-lg border-0">
                    <div class="card-header border-0 py-4 px-4 d-flex justify-content-between align-items-center" style="background-color: var(--bg-header);">
                        <div>
                            <h4 class="mb-1 fw-bold text-dark"><i class="bi bi-terminal me-2 text-primary"></i>Query Runner</h4>
                            <p class="text-secondary small mb-0">Execute SQL commands directly against the database</p>
                        </div>
                        <div class="d-flex gap-3 align-items-center">
                            <div class="input-group shadow-sm" style="width: auto;">
                                <span class="input-group-text" style="background-color: var(--bg-body); border-color: var(--border-color); color: var(--text-main);">
                                    <i class="bi bi-database text-primary"></i>
                                </span>
                                <asp:DropDownList ID="ddlDatabase" runat="server" CssClass="form-select py-2 fw-bold" 
                                    style="min-width: 250px; background-color: var(--bg-card); border-color: var(--border-color); color: var(--text-main) !important;">
                                </asp:DropDownList>
                            </div>
                            <asp:LinkButton ID="btnExecute" runat="server" CssClass="btn btn-primary btn-modern px-4 py-2 shadow-sm" OnClick="btnExecute_Click" OnClientClick="showLoading();">
                                <i class="bi bi-play-fill me-1"></i> Execute Query
                            </asp:LinkButton>
                        </div>
                    </div>
                    
                    <div class="card-body px-4">
                        <!-- SQL Editor Area -->
                        <div class="mb-4 position-relative">
                            <label class="form-label text-secondary small fw-bold mb-2">SQL COMMAND EDITOR</label>
                            <asp:TextBox ID="txtQuery" runat="server" TextMode="MultiLine" Rows="12" 
                                CssClass="form-control font-monospace p-3 fs-6 shadow-sm border-2" 
                                placeholder="-- Write your SQL query here (SELECT...)"
                                style="background-color: var(--bg-body); color: var(--text-main); border-color: var(--border-color); resize: vertical; width: 100% !important; min-width: 100%;"></asp:TextBox>
                        </div>
                    </div>
            </div>
        </div>
    </div>

        <!-- Results Breakout (Full Width) -->
        <div class="full-width-breakout mt-4 px-sm-5 px-3 pb-5">
            <!-- Results & Messages Tabs -->
            <div>
                <ul class="nav nav-tabs border-bottom-0 gap-2" id="queryTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active btn-modern border-0 px-4 py-2" id="results-tab" data-bs-toggle="tab" data-bs-target="#results" type="button" role="tab">
                            <i class="bi bi-table me-2"></i>Results
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link btn-modern border-0 px-4 py-2" id="messages-tab" data-bs-toggle="tab" data-bs-target="#messages" type="button" role="tab">
                            <i class="bi bi-info-circle me-2"></i>Messages
                        </button>
                    </li>
                </ul>
                            
                <div class="tab-content card border rounded-3 overflow-hidden" id="queryTabsContent" style="background-color: var(--bg-card); min-height: 300px;">
                    <!-- Tab Results -->
                    <div class="tab-pane fade show active p-0" id="results" role="tabpanel">
                        <div id="resultsContainer" class="p-3">
                            <asp:PlaceHolder ID="phGrids" runat="server"></asp:PlaceHolder>
                            <asp:Literal ID="litEmpty" runat="server">
                                <div class="p-5 text-center text-secondary">
                                    <i class="bi bi-inbox display-4 d-block mb-3 opacity-25"></i>
                                    No data to display. Run a SELECT query to see results.
                                </div>
                            </asp:Literal>
                        </div>
                    </div>
                                
                    <!-- Tab Messages -->
                    <div class="tab-pane fade p-4" id="messages" role="tabpanel">
                        <asp:Literal ID="litMessages" runat="server"></asp:Literal>
                    </div>
                </div>
            </div>
        </div>

    <style>
        .full-width-breakout {
            margin-left: calc(-50vw + 50%);
            margin-right: calc(-50vw + 50%);
            width: 100vw;
            max-width: 100vw;
        }
        
        .nav-tabs .nav-link {
            color: var(--text-muted);
            background-color: var(--table-header);
            border-radius: 8px 8px 0 0 !important;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.2s;
        }
        .nav-tabs .nav-link.active {
            color: var(--primary-blue) !important;
            background-color: var(--bg-card) !important;
            border: 1px solid var(--border-color) !important;
            border-bottom: none !important;
        }
        .nav-tabs .nav-link:hover:not(.active) {
            background-color: var(--border-color);
            color: var(--text-main);
        }
    </style>

    <script>
        $(document).ready(function() {
            const pendingSQL = sessionStorage.getItem('pendingSQL');
            if (pendingSQL) {
                const editor = document.getElementById('<%= txtQuery.ClientID %>');
                if (editor) {
                    editor.value = pendingSQL;
                    sessionStorage.removeItem('pendingSQL');
                    showAlert('SQL Loaded', 'Generated script has been loaded from SP Maker', 'info');
                }
            }
        });

        function switchTab(tabId) {
            var triggerEl = document.querySelector('#' + tabId);
            if (triggerEl) {
                var tab = new bootstrap.Tab(triggerEl);
                tab.show();
            }
        }

        function exportToCSV(button) {
            const tableContainer = button.closest('.result-set-wrapper');
            const table = tableContainer.querySelector('table');
            const rows = table.querySelectorAll('tr');
            let csv = [];
            
            for (let i = 0; i < rows.length; i++) {
                const row = [], cols = rows[i].querySelectorAll('td, th');
                for (let j = 0; j < cols.length; j++) {
                    let data = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, '').replace(/(\s\s+)/gm, ' ');
                    data = data.replace(/"/g, '""');
                    row.push('"' + data + '"');
                }
                csv.push(row.join(','));
            }

            const csvContent = "data:text/csv;charset=utf-8," + csv.join('\n');
            const encodedUri = encodeURI(csvContent);
            const link = document.createElement("a");
            link.setAttribute("href", encodedUri);
            link.setAttribute("download", "query_result_" + new Date().getTime() + ".csv");
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    </script>
</asp:Content>
