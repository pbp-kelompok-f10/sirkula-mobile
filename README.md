<p align="center">
  <a href="https://sirkula.pbp.cs.ui.ac.id">
    <img src="logo/sirkula.png" alt="Sirkula Logo" width="300">
  </a>
</p>

<p align="center">
  <b>PBP Final Project — Kelompok F10</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Django-092E20?style=flat&logo=django&logoColor=white" alt="Django">
  <img src="https://img.shields.io/badge/Django_REST-ff1709?style=flat&logo=django&logoColor=white" alt="Django REST Framework">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white" alt="PostgreSQL">
</p>

## 📖 Tentang Sirkula

**Sirkula** adalah platform marketplace dan digital wardrobe yang bertujuan untuk mendorong konsumsi berkelanjutan melalui pemanfaatan kembali barang layak pakai, pertukaran produk, serta eksplorasi gaya berpakaian berbasis kecerdasan buatan.

Melalui Sirkula, pengguna dapat menemukan barang preloved di sekitar mereka, menawarkan barang untuk dijual atau ditukar, serta mengelola koleksi pakaian pribadi melalui lemari digital.

Fashion menjadi fokus utama platform ini. Melalui fitur **AI Stylist**, Sirkula dikembangkan untuk membantu pengguna menemukan kombinasi outfit berdasarkan pakaian yang sudah mereka miliki, sehingga pengguna dapat mengeksplorasi gaya berpakaian tanpa harus selalu membeli pakaian baru.

Sirkula juga menyediakan **Discovery Map** yang memungkinkan pengguna menemukan produk dan penjual berdasarkan lokasi geografis, radius pencarian, serta kata kunci.

Proyek ini dikembangkan oleh **Kelompok F10** sebagai bagian dari mata kuliah **Pemrograman Berbasis Platform (PBP)** di Fakultas Ilmu Komputer, Universitas Indonesia.

Pada tahap awal, Sirkula dikembangkan sebagai aplikasi web menggunakan Django. Pengembangan selanjutnya berfokus pada implementasi aplikasi mobile lintas platform menggunakan **Flutter**, dengan Django REST Framework sebagai backend API.

## 👥 Peran Pengguna

| Aktor | Peran dalam Sirkula |
|---|---|
| **Pengunjung** | Menjelajahi katalog, melihat detail produk, dan mencari produk atau toko melalui Discovery Map. Dapat mendaftar atau masuk untuk menggunakan fitur yang memerlukan akun. |
| **Pembeli** | Mencari barang preloved dan melakukan pembelian serta melihat status dan riwayat transaksi. |
| **Penjual** | Menambahkan dan mengelola produk miliknya, termasuk informasi dan ketersediaan barang. |
| **Pengguna barter** | Menawarkan barang untuk ditukar dan menanggapi penawaran pertukaran. |
| **Pemilik wardrobe** | Mengelola koleksi pakaian pribadi dan menggunakan AI Stylist untuk mengeksplorasi kombinasi outfit. |
| **Administrator** | Mengelola data dan administrasi aplikasi melalui fasilitas administrasi Django sesuai hak aksesnya. |

## 🔗 Integrasi Data Mobile dan Web PWS

Aplikasi mobile menggunakan backend Django dari [Sirkula Web App](https://github.com/pbp-kelompok-f10/sirkula). Endpoint Django REST Framework (DRF) memakai model dan database yang sama dengan situs web. Aplikasi mobile tidak mengakses database secara langsung.

1. Pengguna melakukan tindakan di aplikasi Flutter, misalnya mencari produk atau memperbarui koleksi wardrobe.
2. Flutter mengirim request HTTP ke API DRF dan menerima respons JSON. Untuk unggahan gambar, gunakan `multipart/form-data`.
3. DRF mengautentikasi pengguna, memeriksa hak akses dan memvalidasi input sebelum menjalankan aturan bisnis Django.
4. Backend membaca atau memperbarui database yang digunakan situs web. Perubahan dapat dilihat di platform lain setelah data dimuat ulang; tidak ada asumsi sinkronisasi real-time.
5. Flutter mengolah respons atau kesalahan dan memperbarui tampilan. Data aplikasi harus diambil dan dikirim melalui endpoint, bukan disimpan sebagai data statis di dalam aplikasi.

## Features

| Modul | Deskripsi |
|---|---|
| 🛍️ **Marketplace** | Menjelajahi, mencari, dan menawarkan barang preloved melalui katalog dan detail produk. |
| 🗺️ **Discovery Map** | Menemukan produk dan penjual di sekitar pengguna berdasarkan lokasi, radius, dan kata kunci. |
| 🔄 **Transaction & Barter** | Mengelola pembelian dan pertukaran barang beserta status dan riwayat transaksi. |
| 👕 **Personal Wardrobe** | Menyimpan, mengategorikan, dan mengelola koleksi pakaian pribadi secara digital. |
| ✨ **AI Stylist** | Menghasilkan rekomendasi kombinasi outfit berdasarkan koleksi pakaian pengguna. |
| 👤 **User Profile** | Autentikasi, pengelolaan profil, dan informasi aktivitas pengguna. |

Fitur-fitur tersebut dikembangkan secara bertahap dan dapat mengalami penyesuaian selama proses implementasi.

## 🛠️ Tech Stack

Sirkula menggunakan arsitektur **client-server**, dengan Flutter sebagai mobile client dan Django REST Framework sebagai penyedia layanan backend.

### 📱 Mobile Application

| Teknologi | Kegunaan |
|---|---|
| **Flutter & Dart** | Framework utama pengembangan aplikasi mobile lintas platform. |
| **Material Design 3** | Fondasi design system dan komponen antarmuka. |
| **Riverpod 3** | State management dan dependency injection. |
| **go_router** | Navigasi, nested routing, dan deep linking. |
| **Dio** | HTTP client untuk komunikasi dengan REST API. |
| **Freezed & json_serializable** | Immutable data models dan serialisasi JSON. |
| **flutter_secure_storage** | Penyimpanan kredensial autentikasi secara aman. |
| **image_picker** | Pengambilan gambar melalui galeri dan kamera perangkat. |
| **cached_network_image** | Pengelolaan cache gambar dari jaringan. |

### ⚙️ Backend & Infrastructure

| Teknologi | Kegunaan |
|---|---|
| **Python & Django** | Backend framework dan implementasi business logic. |
| **Django REST Framework** | Penyedia REST API untuk aplikasi mobile. |
| **PostgreSQL** | Database relasional utama. |
| **PostGIS** | Dukungan spatial queries untuk pencarian berbasis lokasi. |
| **drf-spectacular** | Dokumentasi dan spesifikasi OpenAPI. |
| **S3-Compatible Storage** | Penyimpanan gambar produk dan koleksi wardrobe. |
| **GitHub Actions** | Continuous integration, testing, dan otomatisasi build. |

### 🌍 Geospatial Services

| Teknologi | Kegunaan |
|---|---|
| **MapLibre GL** | Rendering peta interaktif pada aplikasi mobile. |
| **OpenFreeMap Liberty** | Vector map style berbasis data OpenStreetMap. |
| **geolocator** | Akses lokasi geografis perangkat. |
| **Nominatim-Compatible Geocoding** | Konversi alamat dan koordinat melalui backend. |
| **GeoDjango & PostGIS** | Penyimpanan serta pencarian data spasial. |

### 🤖 AI Integration

AI Stylist menggunakan arsitektur backend-mediated inference. Aplikasi Flutter berkomunikasi dengan Django API, sementara pemrosesan AI dijalankan melalui layanan inference terpisah.

Pendekatan ini menjaga kredensial layanan AI tetap berada di sisi server dan memungkinkan penggantian model tanpa memerlukan perubahan pada aplikasi mobile.

## 🏗️ System Architecture

```text
┌─────────────────────────────────────────┐
│             Flutter Mobile App          │
│                                         │
│  UI / Widgets       Material Design 3   │
│  State Management   Riverpod            │
│  Navigation         go_router           │
│  Networking         Dio                 │
│  Maps               MapLibre GL         │
└─────────────────────┬───────────────────┘
                      │
                 HTTPS / JSON
                      │
                      ▼
┌─────────────────────────────────────────┐
│           Django REST Framework         │
│                                         │
│  Authentication & Authorization         │
│  Marketplace & Transactions             │
│  Wardrobe Management                    │
│  Geospatial Search                      │
│  AI Stylist Integration                 │
└────────────┬────────────────┬───────────┘
             │                │
             ▼                ▼
┌──────────────────┐  ┌──────────────────┐
│   PostgreSQL     │  │  Object Storage  │
│   + PostGIS      │  │  S3-Compatible   │
└──────────────────┘  └──────────────────┘
             │
             │ External Services
             ▼
┌─────────────────────────────────────────┐
│  Geocoding / Geolocation / AI Inference │
└─────────────────────────────────────────┘
```

### Architectural Principles

Pengembangan Sirkula mengikuti beberapa prinsip utama:

- **Separation of Concerns:** Antarmuka, pengelolaan state, akses data, dan business logic dipisahkan berdasarkan tanggung jawabnya.
- **Feature-First Architecture:** Modul Flutter diorganisasikan berdasarkan fitur untuk mempermudah pengembangan paralel.
- **Repository Pattern:** Interaksi dengan API dan sumber data diabstraksikan melalui repository.
- **API-Driven Development:** Komunikasi antara mobile client dan backend menggunakan REST API dengan kontrak yang terdokumentasi.
- **Server-Side Business Logic:** Validasi dan aturan bisnis utama tetap dijalankan melalui Django.
- **Secure by Design:** Kredensial sensitif tidak disimpan secara langsung pada source code aplikasi.

## 📁 Project Structure

```text
sirkula/
├── mobile/
│   ├── android/
│   ├── ios/
│   ├── assets/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/
│   │   │   ├── app.dart
│   │   │   ├── router.dart
│   │   │   └── theme/
│   │   ├── core/
│   │   │   ├── network/
│   │   │   ├── storage/
│   │   │   ├── errors/
│   │   │   └── widgets/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── marketplace/
│   │   │   ├── discovery/
│   │   │   ├── transactions/
│   │   │   ├── wardrobe/
│   │   │   ├── stylist/
│   │   │   └── profile/
│   │   └── shared/
│   ├── test/
│   ├── integration_test/
│   └── pubspec.yaml
│
├── backend/
│   ├── apps/
│   ├── main/
│   ├── sirkula/
│   ├── templates/
│   ├── static/
│   ├── manage.py
│   ├── requirements.txt
│   └── .env.example
│
├── .github/
│   └── workflows/
├── .gitignore
└── README.md
```

Setiap feature Flutter dapat dibagi menjadi tiga bagian utama:

```text
features/
└── marketplace/
    ├── data/
    │   ├── models/
    │   ├── repositories/
    │   └── services/
    ├── domain/
    └── presentation/
        ├── screens/
        ├── widgets/
        └── providers/
```

## 🚀 Installation

### Prerequisites
- Git
- Flutter SDK dan Dart SDK yang kompatibel
- Android Studio dan Android SDK
- Python 3.11 atau lebih baru yang kompatibel dengan dependensi backend
- PostgreSQL dan PostGIS, jika menjalankan database produksi secara lokal
- Editor seperti VS Code atau Android Studio

Untuk menjalankan aplikasi pada iOS, diperlukan macOS dan Xcode.

Verifikasi instalasi Flutter menggunakan:

```bash
flutter doctor
```

### 1. Clone Repository
Backend
```bash
git clone https://github.com/pbp-kelompok-f10/sirkula.git
cd sirkula
```

Frontend
```bash
git clone https://github.com/pbp-kelompok-f10/sirkula-mobile.git
cd sirkula
```

### 2. Backend Setup

Masuk ke direktori backend:

```bash
cd sirkula
```

Buat virtual environment:

```bash
python -m venv env
```

Aktifkan virtual environment.

**macOS / Linux**

```bash
source env/bin/activate
```

**Windows PowerShell**

```powershell
.\env\Scripts\Activate.ps1
```

Instal dependensi:

```bash
python -m pip install -r requirements.txt
```

Salin konfigurasi environment:

**macOS / Linux**

```bash
cp .env.example .env
```

**Windows PowerShell**

```powershell
Copy-Item .env.example .env
```

Sesuaikan konfigurasi database, secret key, dan layanan eksternal berdasarkan kebutuhan environment.

Jalankan migrasi dan development server:

```bash
python manage.py migrate
python manage.py runserver
```

Backend secara default dapat diakses melalui:

```text
http://127.0.0.1:8000/
```

REST API tersedia melalui prefix:

```text
/api/v1/
```

### 3. Flutter Setup

Buka terminal baru dan masuk ke direktori mobile:

```bash
cd sirkula-mobile
```

Instal dependensi:

```bash
flutter pub get
```

Periksa perangkat yang tersedia:

```bash
flutter devices
```

Jalankan aplikasi:

```bash
flutter run
```

Untuk Android Emulator, backend yang berjalan pada komputer host umumnya dapat diakses melalui:

```text
http://10.0.2.2:8000
```

Alamat backend dikonfigurasikan melalui Dart environment:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Untuk perangkat fisik, gunakan alamat backend yang dapat diakses melalui jaringan perangkat tersebut. Pastikan konfigurasi Django `ALLOWED_HOSTS`, jaringan, dan kebijakan HTTP/HTTPS platform telah disesuaikan.

### 4. Build Android Application

Untuk menghasilkan APK:

```bash
flutter build apk --release
```

Untuk menghasilkan Android App Bundle:

```bash
flutter build appbundle --release
```

Build release memerlukan konfigurasi signing dan environment produksi yang sesuai sebelum didistribusikan.

## 🔌 API Integration
Prefix: `/api/v1/`, di mana `{id}` adalah ID objek dan `{uuid}` adalah ID percakapan.

| Modul | Method | Endpoint setelah `/api/v1/` | Kegunaan |
|---|---|---|---|
| Akun | `POST` | `accounts/register/`, `accounts/login/`, `accounts/logout/` | Registrasi, memperoleh token, dan mencabut token |
| Profil | `GET`, `PUT`, `PATCH` | `accounts/profile/` | Membaca dan mengubah profil sendiri |
| Marketplace | `GET` | `marketplace/products/`, `marketplace/products/{id}/` | Katalog dan detail produk |
| Marketplace | `GET`, `POST` | `marketplace/my/products/` | Daftar dan tambah produk sendiri |
| Marketplace | `GET`, `PUT`, `PATCH`, `DELETE` | `marketplace/my/products/{id}/` | Kelola produk sendiri |
| Marketplace | `GET`, `POST` | `marketplace/my/products/{id}/images/` | Daftar dan tambah gambar galeri |
| Marketplace | `GET`, `PUT`, `PATCH`, `DELETE` | `marketplace/my/products/{id}/images/{image_id}/` | Kelola gambar galeri |
| Discovery Map | `GET` | `marketplace/map/locations/`, `marketplace/map/nearby/`, `marketplace/map/geocode/`, `marketplace/map/reverse-geocode/` | Lokasi, pencarian sekitar dan geocoding |
| Discovery Map | `GET`, `POST` | `marketplace/map/saved-places/` | Daftar dan tambah tempat tersimpan |
| Discovery Map | `GET`, `PUT`, `PATCH`, `DELETE` | `marketplace/map/saved-places/{id}/` | Kelola tempat tersimpan sendiri |
| Wardrobe | `GET`, `POST` | `wardrobe/categories/`, `wardrobe/items/` | Daftar dan tambah kategori atau pakaian |
| Wardrobe | `GET`, `PUT`, `PATCH`, `DELETE` | `wardrobe/categories/{id}/`, `wardrobe/items/{id}/` | Kelola kategori atau pakaian sendiri |
| Wardrobe | `GET` | `wardrobe/photos/{id}/` | Mengambil foto privat yang diizinkan |
| AI Stylist | `GET`, `POST` | `outfits/conversations/` | Daftar dan mulai percakapan |
| AI Stylist | `GET` | `outfits/conversations/{uuid}/` | Detail percakapan sendiri |
| AI Stylist | `POST` | `outfits/conversations/{uuid}/messages/` | Mengirim pesan |
| AI Stylist | `GET`, `POST` | `outfits/conversations/{uuid}/preview/` | Memeriksa atau meminta preview |
| AI Stylist | `GET` | `outfits/conversations/{uuid}/preview/image/` | Mengambil gambar preview |
| Transaksi | `GET`, `DELETE` | `transactions/cart/` | Melihat atau mengosongkan keranjang |
| Transaksi | `POST`, `DELETE` | `transactions/cart/items/{id}/` | Menambah atau menghapus produk di keranjang |
| Transaksi | `POST` | `transactions/checkout/` | Membuat pesanan dan pembayaran |
| Transaksi | `GET` | `transactions/orders/`, `transactions/orders/{id}/` | Daftar dan detail pesanan |
| Transaksi | `POST` | `transactions/orders/{id}/status/`, `transactions/orders/{id}/payment-status/` | Memperbarui status atau memeriksa pembayaran |
| Transaksi | `GET`, `POST` | `transactions/notifications/` (`GET`), `transactions/notifications/{id}/read/` (`POST`) | Notifikasi transaksi |
| Barter | `GET`, `POST` | `bartering/offers/` | Daftar dan buat penawaran |
| Barter | `GET` | `bartering/offers/{id}/`, `bartering/transactions/`, `bartering/transactions/{id}/` | Detail penawaran dan transaksi barter |
| Barter | `POST` | `bartering/offers/{id}/{action}/` | Aksi `accept`, `reject`, `cancel`, `shipping`, atau `received` |
| Ulasan | `GET`, `POST` | `core/reviews/` | Daftar dan buat ulasan |
| Ulasan | `GET`, `PUT`, `PATCH`, `DELETE` | `core/reviews/{id}/` | Detail dan pengelolaan ulasan |
| Ulasan | `PUT`, `DELETE` | `core/reviews/{id}/like/` | Menyukai atau membatalkan suka |

Login menerima `email` dan `password`, lalu mengembalikan `token`. Kirim `Authorization: Token <token>` pada request yang memerlukan autentikasi, gunakan HTTPS di prod dan pastikan token aman. Token DRF tidak memiliki masa kedaluwarsa bawaan dan satu akun menggunakan satu token. Session Django juga didukung dengan CSRF untuk request yang mengubah data.

Keranjang memakai session Django, sehingga klien harus mempertahankan cookie session selain token. Endpoint privat membatasi data berdasarkan pengguna atau perannya. Pencarian geocoding, pembayaran Midtrans, dan AI Stylist bergantung pada konfigurasi serta ketersediaan layanan eksternal.

## 🧪 Testing & Quality Assurance

Pengujian dilakukan pada frontend mobile maupun backend untuk menjaga konsistensi dan kualitas aplikasi.

### Flutter

Static analysis:

```bash
flutter analyze
```

Unit dan widget testing:

```bash
flutter test
```

Integration testing:

```bash
flutter test integration_test
```

### Django

System checks:

```bash
python manage.py check
```

Migration consistency:

```bash
python manage.py makemigrations --check --dry-run
```

Backend tests:

```bash
python manage.py test
```

Pengujian backend dan mobile direncanakan diintegrasikan dalam GitHub Actions untuk mendeteksi regresi sebelum perubahan digabungkan ke branch utama.

## 🔐 Security Considerations

Sirkula menerapkan beberapa prinsip keamanan untuk melindungi data dan aktivitas pengguna:

- Menggunakan HTTPS untuk komunikasi aplikasi dengan server produksi.
- Menyimpan kredensial dan konfigurasi sensitif melalui environment variables.
- Menyimpan token autentikasi mobile menggunakan secure storage.
- Menerapkan authentication dan object-level authorization pada endpoint yang relevan.
- Melakukan validasi input dan pembatasan ukuran maupun tipe file upload.
- Membatasi akses data wardrobe pribadi berdasarkan kepemilikan pengguna.
- Menjalankan komunikasi dengan layanan AI melalui backend.
- Menambahkan throttling atau rate limiting pada endpoint yang rentan terhadap penyalahgunaan.

## 👥 Development Team

| Nama | NPM | Pembagian Modul |
|---|---|---|
| **Zayyan Ramadzaki Firdaus** | 2506550955 | Marketplace dan Discovery Map |
| **Rayyan Raditia Pramana** | 2506598955 | Transcations dan Outfits |
| **Ilman Ghani Awliya** | 2506656803 | Bartering Systems |
| **Farel Boston Corinthians Nadeak** | 2506548490 | Wardrobe |
| **Marwa Muhlashon** | 2506552714 | Accounts dan Profile |

## 🎯 Target Users

Sirkula ditujukan terutama bagi mahasiswa dan generasi Z yang tertarik pada fashion, gaya hidup berkelanjutan, serta pemanfaatan barang preloved.

Platform ini dirancang untuk membantu pengguna menemukan pilihan fashion yang lebih terjangkau, mengeksplorasi kombinasi outfit, dan memperpanjang masa pakai barang melalui aktivitas jual beli maupun barter.

Melalui pendekatan berbasis lokasi, Sirkula juga berupaya mendukung interaksi dan pertukaran barang dalam komunitas terdekat.

## 🔗 Project Links

- **Repository:** https://github.com/pbp-kelompok-f10/sirkula-mobile
- **Figma:** https://www.figma.com/design/TyoL1i8RIAmSWF3XUgPpNu/PBP-ZBMRI



<p align="center">
  <b>Dibuat oleh Kelompok F10</b>
</p>

<p align="center">
  Faculty of Computer Science<br>
  Universitas Indonesia
</p>

<p align="center">
  ♻️ <i>Giving pre-loved items a second life.</i>
</p>
