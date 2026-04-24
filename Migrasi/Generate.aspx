<%@ Page Title="Generate Data" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Generate.aspx.cs" Inherits="Migrasi.Generate" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <div class="row mt-4">
            <div class="col-12">
                <div class="card card-modern">
                    <div class="card-header border-0 py-4 px-4 d-flex justify-content-between align-items-center" style="background-color: var(--bg-header);">
                        <div>
                            <h4 class="mb-1 fw-bold text-dark">Data Generation</h4>
                            <p class="text-secondary small mb-0">Export data to standardized TXT format</p>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <div class="d-flex align-items-center bg-light p-1 rounded-3 border">
                                <span class="small fw-bold text-secondary px-3">CONFIG</span>
                                <asp:DropDownList ID="ddlConfig" runat="server" CssClass="form-select form-select-sm border-0 shadow-sm fw-500" style="width: 250px; border-radius: 6px;" DataTextField="FileGenerate" DataValueField="NamaSPGenerate">
                                </asp:DropDownList>
                            </div>
                            <asp:Button ID="btnPreview" runat="server" Text="Preview Data" CssClass="btn btn-light btn-modern btn-sm border shadow-sm px-3" OnClick="btnPreview_Click" />
                            <asp:Button ID="btnGenerate" runat="server" Text="Generate TXT" CssClass="btn btn-primary btn-modern btn-sm py-2 shadow-sm px-4" OnClick="btnGenerate_Click" />
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="px-4 py-2 border-bottom d-flex justify-content-between align-items-center" style="background-color: var(--bg-header);">
                            <span class="text-secondary small">Data Preview Area</span>
                            <asp:Label ID="lblTotal" runat="server" CssClass="badge rounded-pill text-primary fw-bold px-3 py-2" Text="0 Records Found" Visible="false"></asp:Label>
                        </div>
                        <div class="table-responsive" style="overflow-x: auto;">
                            <asp:GridView ID="gvProducts" runat="server" CssClass="table table-hover table-modern mb-0" 
                                AllowPaging="True" PageSize="10" OnPageIndexChanging="gvProducts_PageIndexChanging"
                                AutoGenerateColumns="true" GridLines="None">
                                <PagerSettings Visible="false" />
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
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            color: var(--primary-blue);
            border-radius: 4px;
            margin: 0 3px;
            font-size: 14px;
            min-width: 35px;
            text-align: center;
        }
        .custom-pagination .active-page {
            background-color: var(--primary-blue) !important;
            color: #fff !important;
            border-color: var(--primary-blue) !important;
            cursor: default;
        }
        .custom-pagination a:hover:not(.active-page) {
            background-color: var(--table-header);
        }
    </style>
</asp:Content>
