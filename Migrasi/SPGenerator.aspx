<%@ Page Title="SP Generator" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="SPGenerator.aspx.cs" Inherits="Migrasi.SPGenerator" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <div class="row mt-4">
            <div class="col-12">
                <div class="card card-modern">
                    <div class="card-header border-0 py-4 px-4" style="background-color: var(--bg-header);">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h4 class="mb-1 fw-bold text-dark"><i class="bi bi-code-square me-2 text-info"></i>Stored Procedure Maker</h4>
                                <p class="text-secondary small mb-0">Auto-generate SQL Upload SP from TXT file schema</p>
                            </div>
                        </div>
                    </div>
                    <div class="card-body px-4 pb-4">
                        <div class="row g-4 align-items-end mb-4 bg-light p-4 rounded-4 mx-0 mt-2">
                            <div class="col-md-5">
                                <label class="form-label text-secondary small fw-bold">1. SAMPLE TXT FILE</label>
                                <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control form-control-lg fs-6" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label text-secondary small fw-bold">2. PROCEDURE NAME</label>
                                <asp:TextBox ID="txtSPName" runat="server" CssClass="form-control form-control-lg fs-6" placeholder="usp_UploadDataExample" Text="usp_UploadData"></asp:TextBox>
                            </div>
                            <div class="col-md-3">
                                <asp:Button ID="btnGenerate" runat="server" Text="Generate Script" CssClass="btn btn-info text-white btn-modern w-100 shadow-sm" OnClick="btnGenerate_Click" OnClientClick="showLoading('Analyzing File...', 'Detecting columns and data types');" />
                            </div>
                        </div>

                        <div id="resultArea" runat="server" visible="false" class="mt-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h6 class="text-secondary fw-bold mb-0">Generated SQL Script</h6>
                                <button type="button" class="btn btn-light btn-sm px-3" onclick="copyToClipboard()">
                                    <i class="bi bi-clipboard me-1"></i> Copy Script
                                </button>
                            </div>
                            <div class="bg-dark rounded-4 shadow-inner overflow-hidden" style="position: relative; width: 100%;">
                                <asp:TextBox ID="txtResult" runat="server" TextMode="MultiLine" 
                                    style="height: 500px; width: 100% !important; max-width: none !important; display: block !important; background: transparent; color: #22c55e; border: none; font-family: 'JetBrains Mono', monospace; font-size: 0.9rem; padding: 25px; resize: none; outline: none; white-space: pre;" 
                                    ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        function copyToClipboard() {
            const copyText = document.getElementById('<%= txtResult.ClientID %>');
            copyText.select();
            copyText.setSelectionRange(0, 99999);
            navigator.clipboard.writeText(copyText.value);
            showAlert('Success', 'Script copied to clipboard!', 'success');
        }
    </script>
</asp:Content>
