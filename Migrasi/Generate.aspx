<%@ Page Title="Generate Data" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Generate.aspx.cs" Inherits="Migrasi.Generate" %>

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
                                <asp:DropDownList ID="ddlConfig" runat="server" CssClass="form-select form-select-sm border-0 shadow-sm fw-500" style="width: 250px; border-radius: 6px;" DataTextField="FileGenerate" DataValueField="ID">
                                </asp:DropDownList>
                            </div>
                            <asp:Button ID="btnPreview" runat="server" Text="Preview Data" CssClass="btn btn-light btn-modern btn-sm border shadow-sm px-3" OnClick="btnPreview_Click" />
                            <asp:Button ID="btnGenerate" runat="server" Text="Generate TXT" CssClass="btn btn-primary btn-modern btn-sm py-2 shadow-sm px-4" OnClick="btnGenerate_Click" OnClientClick="showLoading('Generating Data...', 'Preparing your file for download', true);" />
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
                        <div class="custom-pagination py-4 d-flex justify-content-center align-items-center gap-1">
                            <asp:LinkButton ID="btnFirst" runat="server" CssClass="btn-page shadow-sm" OnClick="Pager_Click" CommandArgument="First" ToolTip="First Page"><i class="bi bi-chevron-double-left"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnPrev" runat="server" CssClass="btn-page shadow-sm" OnClick="Pager_Click" CommandArgument="Prev" ToolTip="Previous Page"><i class="bi bi-chevron-left"></i></asp:LinkButton>
                            
                            <div class="d-flex gap-1 mx-2 overflow-auto no-scrollbar" style="max-width: 60vw;">
                                <asp:Repeater ID="rptPager" runat="server" OnItemCommand="rptPager_ItemCommand">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkPage" runat="server" 
                                            Text='<%# Eval("Text") %>' 
                                            CommandArgument='<%# Eval("Value") %>' 
                                            CssClass='<%# (bool)Eval("IsActive") ? "btn-page active-page shadow-sm" : "btn-page shadow-sm" %>'
                                            Enabled='<%# !(bool)Eval("IsActive") %>'>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                            <asp:LinkButton ID="btnNext" runat="server" CssClass="btn-page shadow-sm" OnClick="Pager_Click" CommandArgument="Next" ToolTip="Next Page"><i class="bi bi-chevron-right"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnLast" runat="server" CssClass="btn-page shadow-sm" OnClick="Pager_Click" CommandArgument="Last" ToolTip="Last Page"><i class="bi bi-chevron-double-right"></i></asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <style>
        .custom-pagination .btn-page {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0;
            width: 38px;
            height: 38px;
            text-decoration: none;
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            color: var(--text-main);
            border-radius: 10px;
            font-size: 0.85rem;
            font-weight: 600;
            transition: all 0.2s;
        }
        .custom-pagination .active-page {
            background-color: var(--primary-blue) !important;
            color: #fff !important;
            border-color: var(--primary-blue) !important;
            box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3) !important;
        }
        .custom-pagination .btn-page:hover:not(.active-page):not(:disabled) {
            background-color: var(--table-header);
            border-color: var(--primary-blue);
            color: var(--primary-blue);
            transform: translateY(-2px);
        }
        .custom-pagination .btn-page:disabled, 
        .custom-pagination .btn-page[enabled="false"] {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none !important;
        }
        .no-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .no-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
</asp:Content>
