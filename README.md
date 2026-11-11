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

REST API direncanakan tersedia melalui prefix:

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

Flutter menggunakan Django REST Framework sebagai sumber data utama untuk autentikasi, marketplace, wardrobe, transaksi, dan AI Stylist.

Contoh rancangan endpoint:

| Method | Endpoint | Deskripsi |
|---|---|---|
| `POST` | `/api/v1/auth/login/` | Autentikasi pengguna |
| `GET` | `/api/v1/products/` | Mendapatkan daftar produk |
| `GET` | `/api/v1/products/{id}/` | Mendapatkan detail produk |
| `POST` | `/api/v1/products/` | Menambahkan produk |
| `GET` | `/api/v1/discovery/` | Pencarian produk berdasarkan lokasi |
| `GET` | `/api/v1/wardrobe/` | Mendapatkan koleksi pakaian |
| `POST` | `/api/v1/wardrobe/` | Menambahkan pakaian |
| `GET` | `/api/v1/transactions/` | Riwayat transaksi |
| `POST` | `/api/v1/stylist/recommendations/` | Meminta rekomendasi outfit |

Endpoint tersebut merupakan **rancangan API** dan dapat berubah mengikuti implementasi backend.

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

| Nama | NPM | Tanggung Jawab Sebelumnya |
|---|---|---|
| **Zayyan Ramadzaki Firdaus** | 2506550955 | Discovery Map dan integrasi layanan lokasi |
| **Rayyan Raditia Pramana** | 2506598955 | Homepage, dataset fashion, dan integrasi AI |
| **Ilman Ghani Awliya** | 2506656803 | Marketplace, transaksi, barter, dan desain antarmuka |
| **Farel Boston Corinthians Nadeak** | 2506548490 | Personal Wardrobe dan integrasi rekomendasi outfit |
| **Marwa Muhlashon** | 2506552714 | Profil pengguna dan desain UI/UX |

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
