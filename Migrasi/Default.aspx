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
                    
                    <div class="row g-4 mt-2 text-start">
                        
                        <!-- SECTION: OPERATIONS -->
                        <div class="col-12 mt-5 mb-2">
                            <h5 class="fw-bold text-dark border-bottom pb-2"><i class="bi bi-rocket-takeoff me-2 text-primary"></i>Data Operations</h5>
                        </div>
                        
                        <!-- Card: Generate -->
                        <div class="col-md-6">
                            <a href="Generate" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h2 mb-3 text-warning opacity-75"><i class="bi bi-file-earmark-arrow-down"></i></div>
                                        <h5 class="fw-bold text-dark">Data Generate</h5>
                                        <p class="small text-secondary mb-0">Ekspor data ke format TXT standar yang siap didistribusikan.</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                        <!-- Card: Upload -->
                        <div class="col-md-6">
                            <a href="Upload" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h2 mb-3 text-primary opacity-75"><i class="bi bi-file-earmark-arrow-up"></i></div>
                                        <h5 class="fw-bold text-dark">Data Upload</h5>
                                        <p class="small text-secondary mb-0">Unggah TXT dan masukkan otomatis ke tabel Database via SP.</p>
                                    </div>
                                </div>
                            </a>
                        </div>

                        <!-- SECTION: CONFIGURATIONS -->
                        <div class="col-12 mt-5 mb-2">
                            <h5 class="fw-bold text-dark border-bottom pb-2"><i class="bi bi-gear me-2 text-secondary"></i>Configurations & Master Data</h5>
                        </div>

                        <!-- Card: DB Master -->
                        <div class="col-md-4">
                            <a href="DatabaseMaster" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h2 mb-3 text-warning opacity-75"><i class="bi bi-server"></i></div>
                                        <h5 class="fw-bold text-dark">Database Master</h5>
                                        <p class="small text-secondary mb-0">Kelola daftar database sistem dan sinkronisasi otomatis.</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                        <!-- Card: Config Center -->
                        <div class="col-md-4">
                            <a href="Maintenance" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h2 mb-3 text-secondary opacity-75"><i class="bi bi-gear-fill"></i></div>
                                        <h5 class="fw-bold text-dark">Config Center</h5>
                                        <p class="small text-secondary mb-0">Kelola pemetaan SP dan file untuk alur migrasi data utama.</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                        <!-- Card: Mapping Center -->
                        <div class="col-md-4">
                            <a href="Mapping" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h2 mb-3 text-success opacity-75"><i class="bi bi-intersect"></i></div>
                                        <h5 class="fw-bold text-dark">Mapping Center</h5>
                                        <p class="small text-secondary mb-0">Maintenance tabel padanan (Mapping Key, From Code & To Code).</p>
                                    </div>
                                </div>
                            </a>
                        </div>

                        <!-- SECTION: DEV TOOLS -->
                        <div class="col-12 mt-5 mb-2">
                            <h5 class="fw-bold text-dark border-bottom pb-2"><i class="bi bi-tools me-2 text-info"></i>Developer Tools</h5>
                        </div>

                        <!-- Card: SP Maker -->
                        <div class="col-md-4">
                            <a href="SPGenerator" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h2 mb-3 text-info opacity-75"><i class="bi bi-code-square"></i></div>
                                        <h5 class="fw-bold text-dark">SP Maker</h5>
                                        <p class="small text-secondary mb-0">Auto-generate script Stored Procedure Upload dari file TXT.</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                        <!-- Card: Object Search -->
                        <div class="col-md-4">
                            <a href="DatabaseSearch" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h2 mb-3 text-primary opacity-75"><i class="bi bi-search"></i></div>
                                        <h5 class="fw-bold text-dark">Object Search</h5>
                                        <p class="small text-secondary mb-0">Cari tabel atau SP berdasarkan nama atau isi script definisinya.</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                        <!-- Card: Query Runner -->
                        <div class="col-md-4">
                            <a href="Query" class="text-decoration-none h-100">
                                <div class="card card-modern h-100 p-3 transition-transform">
                                    <div class="card-body">
                                        <div class="h2 mb-3 text-danger opacity-75"><i class="bi bi-terminal"></i></div>
                                        <h5 class="fw-bold text-dark">Query Runner</h5>
                                        <p class="small text-secondary mb-0">Eksekusi command SQL langsung dari web tanpa butuh SSMS.</p>
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
