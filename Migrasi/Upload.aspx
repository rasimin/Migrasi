<%@ Page Title="Upload Data" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Upload.aspx.cs" Inherits="Migrasi.Upload" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <div class="row mt-4">
            <div class="col-12">
                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-header bg-success text-white d-flex justify-content-between align-items-center py-3">
                        <h4 class="mb-0">Upload Data from TXT</h4>
                    </div>
                    <div class="card-body">
                        <div class="row g-3 align-items-end mb-4">
                            <div class="col-md-4">
                                <label class="form-label fw-bold">1. Select Configuration</label>
                                <asp:DropDownList ID="ddlConfig" runat="server" CssClass="form-select" DataTextField="FileGenerate" DataValueField="NamaSPUpload">
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">2. Choose TXT File</label>
                                <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-4">
                                <asp:Button ID="btnPreview" runat="server" Text="Preview File" CssClass="btn btn-primary w-100 shadow-sm" OnClick="btnPreview_Click" />
                            </div>
                        </div>

                        <hr />

                        <div id="previewArea" runat="server" visible="false">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="mb-0 text-primary fw-bold">File Content Preview</h5>
                                <asp:Label ID="lblTotal" runat="server" CssClass="badge bg-info text-dark p-2"></asp:Label>
                            </div>
                            
                            <div class="table-responsive" style="max-height: 400px; overflow-y: auto; border: 1px solid #dee2e6;">
                                <asp:GridView ID="gvUploadPreview" runat="server" CssClass="table table-sm table-hover table-bordered mb-0" AutoGenerateColumns="true">
                                    <HeaderStyle CssClass="table-dark sticky-top" />
                                </asp:GridView>
                            </div>

                            <div class="mt-4 text-end">
                                <asp:Button ID="btnProcessUpload" runat="server" Text="Confirm & Process Upload to DB" CssClass="btn btn-success btn-lg shadow-sm" OnClick="btnProcessUpload_Click" OnClientClick="return confirm('Start processing this data to Database?');" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</asp:Content>
