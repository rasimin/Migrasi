<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Migrasi._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <main>
        <section class="py-5 text-center container">
            <div class="row py-lg-5">
                <div class="col-lg-8 col-md-10 mx-auto">
                    <div class="badge text-primary rounded-pill px-4 py-2 mb-3 fw-600" style="background-color: var(--table-header);">MIGRATION SUITE</div>
                    <h1 class="fw-bold text-dark display-4 mb-4" style="letter-spacing: -1.5px;">Simplify Your Data Flow</h1>
                    <p class="lead text-secondary mb-5 px-lg-5">
                        Solusi profesional untuk kebutuhan migrasi data Anda. Tarik data dari database, 
                        simpan dalam format standar, dan unggah kembali dengan akurasi tinggi.
                    </p>
                    
                    <div class="row g-4 mt-2">
                        <div class="col-md-4">
                            <a href="Maintenance" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h1 mb-4 text-primary opacity-75"><i class="bi bi-sliders2-vertical"></i></div>
                                        <h5 class="fw-bold text-dark">Config Center</h5>
                                        <p class="small text-secondary">Kelola pemetaan SP dan file untuk alur data yang fleksibel.</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                        <div class="col-md-4">
                            <a href="Generate" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h1 mb-4 text-success opacity-75"><i class="bi bi-box-arrow-in-down"></i></div>
                                        <h5 class="fw-bold text-dark">Data Generate</h5>
                                        <p class="small text-secondary">Ekspor data ke format TXT standar dengan pembersihan otomatis.</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                        <div class="col-md-4">
                            <a href="Upload" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h1 mb-4 text-info opacity-75"><i class="bi bi-box-arrow-up"></i></div>
                                        <h5 class="fw-bold text-dark">Data Upload</h5>
                                        <p class="small text-secondary">Unggah kembali data Anda ke sistem tujuan dengan aman.</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <style>
        .transition-transform {
            transition: transform 0.2s;
        }
        .transition-transform:hover {
            transform: translateY(-8px);
            border: 1px solid var(--primary-blue);
        }
        .fw-600 { font-weight: 600; }
    </style>

</asp:Content>
