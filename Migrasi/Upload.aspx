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
                                <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control form-control-lg fs-6" />
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
                                <asp:GridView ID="gvUploadPreview" runat="server" CssClass="table table-hover table-modern mb-0" AutoGenerateColumns="true" GridLines="None">
                                </asp:GridView>
                            </div>

                            <div class="mt-5 text-center p-4 rounded-4" style="background-color: var(--bg-body); border: 1px dashed var(--primary-blue);">
                                <p class="text-success small fw-bold mb-3"><i class="bi bi-check-circle-fill me-2"></i>Data analysis complete. Ready for ingestion.</p>
                                <asp:Button ID="btnProcessUpload" runat="server" Text="Execute Database Upload" CssClass="btn btn-success btn-modern px-5 shadow-sm" OnClick="btnProcessUpload_Click" OnClientClick="return confirmDelete(this, 'Process this data to Database?');" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</asp:Content>
