<%@ Page Title="Generate Data" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Generate.aspx.cs" Inherits="Migrasi.Generate" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <div class="row mt-4">
            <div class="col-12">
                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center py-3">
                        <h4 class="mb-0">Product Data Preview</h4>
                        <div class="d-flex align-items-center">
                            <span class="me-2 fw-bold">Select Config:</span>
                            <asp:DropDownList ID="ddlConfig" runat="server" CssClass="form-select form-select-sm me-3" style="width: 250px;" DataTextField="FileGenerate" DataValueField="NamaSPGenerate">
                            </asp:DropDownList>
                            <asp:Button ID="btnPreview" runat="server" Text="Preview Data" CssClass="btn btn-light btn-sm me-2 shadow-sm" OnClick="btnPreview_Click" />
                            <asp:Button ID="btnGenerate" runat="server" Text="Generate to TXT" CssClass="btn btn-outline-light btn-sm shadow-sm me-3" OnClick="btnGenerate_Click" />
                            <asp:Label ID="lblTotal" runat="server" CssClass="badge bg-warning text-dark fw-bold p-2" Text="Total Records: 0" Visible="false"></asp:Label>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive" style="overflow-x: auto; border-bottom: 1px solid #dee2e6;">
                            <asp:GridView ID="gvProducts" runat="server" CssClass="table table-hover table-striped mb-0" 
                                AllowPaging="True" PageSize="10" OnPageIndexChanging="gvProducts_PageIndexChanging"
                                AutoGenerateColumns="true" GridLines="None">
                                <PagerSettings Visible="false" />
                                <HeaderStyle CssClass="table-dark" />
                            </asp:GridView>
                        </div>
                        <div class="custom-pagination py-3 d-flex justify-content-center">
                            <asp:Repeater ID="rptPager" runat="server" OnItemCommand="rptPager_ItemCommand">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkPage" runat="server" 
                                        Text='<%# Container.DataItem %>' 
                                        CommandArgument='<%# Container.DataItem %>' 
                                        CssClass='<%# (int)Container.DataItem - 1 == gvProducts.PageIndex ? "active-page" : "" %>'
                                        Enabled='<%# (int)Container.DataItem - 1 != gvProducts.PageIndex %>'>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <style>
        .custom-pagination a {
            display: block;
            padding: 6px 12px;
            text-decoration: none;
            background-color: #fff;
            border: 1px solid #dee2e6;
            color: #0d6efd;
            border-radius: 4px;
            margin: 0 3px;
            font-size: 14px;
            min-width: 35px;
            text-align: center;
        }
        .custom-pagination .active-page {
            background-color: #0d6efd !important;
            color: #fff !important;
            border-color: #0d6efd !important;
            cursor: default;
        }
        .custom-pagination a:hover:not(.active-page) {
            background-color: #e9ecef;
        }
    </style>
</asp:Content>
