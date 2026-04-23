<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Migrasi._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <main>
        <section class="py-5 text-center container">
            <div class="row py-lg-5">
                <div class="col-lg-8 col-md-10 mx-auto">
                    <h1 class="fw-bold text-primary mb-4">Migration Application</h1>
                    <p class="lead text-muted mb-5">
                        Selamat datang di aplikasi migrasi data. Aplikasi ini dirancang untuk mempermudah proses 
                        pemindahan data antar sistem melalui format file TXT yang terstandarisasi.
                    </p>
                    <div class="row g-4 mt-2">
                        <div class="col-md-4">
                            <div class="card h-100 border-0 shadow-sm p-3">
                                <div class="card-body text-center">
                                    <div class="h1 mb-3 text-primary"><i class="bi bi-gear-fill"></i></div>
                                    <h5 class="fw-bold">1. Maintenance</h5>
                                    <p class="small text-secondary">Konfigurasi pemetaan File dan Stored Procedure untuk Generate & Upload.</p>
                                    <a href="Maintenance" class="btn btn-outline-primary btn-sm rounded-pill px-4">Go to Menu</a>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card h-100 border-0 shadow-sm p-3">
                                <div class="card-body text-center">
                                    <div class="h1 mb-3 text-success"><i class="bi bi-file-earmark-arrow-down-fill"></i></div>
                                    <h5 class="fw-bold">2. Generate</h5>
                                    <p class="small text-secondary">Tarik data dari database dan simpan ke dalam format file TXT yang aman.</p>
                                    <a href="Generate" class="btn btn-outline-success btn-sm rounded-pill px-4">Go to Menu</a>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card h-100 border-0 shadow-sm p-3">
                                <div class="card-body text-center">
                                    <div class="h1 mb-3 text-info"><i class="bi bi-file-earmark-arrow-up-fill"></i></div>
                                    <h5 class="fw-bold">3. Upload</h5>
                                    <p class="small text-secondary">Proses balik file TXT ke dalam database menggunakan pemetaan SP Upload.</p>
                                    <a href="Upload" class="btn btn-outline-info btn-sm rounded-pill px-4">Go to Menu</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>

</asp:Content>
