# Responsi Pemrograman Flutter - Aplikasi Cuaca Open-Meteo

Aplikasi Cuaca berbasis Flutter yang mengimplementasikan arsitektur **Model-View-ViewModel (MVVM)**, **State Management Provider**, **Local Storage (SharedPreferences)**, dan integrasi penuh dengan **Open-Meteo REST API** (Geocoding API dan Forecast API).

---

## Identitas Pengembang
- **Nama**  : [Nama Lengkap Anda]
- **NIM**   : [Nomor Induk Mahasiswa]
- **Shift** : [Shift Praktikum]

---

## 1. Deskripsi Singkat Aplikasi
Aplikasi ini memungkinkan pengguna untuk memantau prakiraan cuaca terkini dan prakiraan harian (7 hari ke depan) berdasarkan lokasi kota di seluruh dunia. Aplikasi ini dilengkapi dengan:
- **Cuaca Terkini**: Menampilkan suhu saat ini, kondisi cuaca (ikon & deskripsi WMO), suhu yang dirasakan (*apparent temperature*), kelembapan udara, kecepatan angin, curah hujan, dan kemungkinan hujan.
- **Pencarian Kota Real-time**: Menggunakan Open-Meteo Geocoding API untuk mencari koordinat dan data geografis kota secara dinamis.
- **Local Storage Terintegrasi**: Menyimpan lokasi favorit dan riwayat pencarian menggunakan `shared_preferences` sehingga data tetap tersimpan saat aplikasi ditutup dan dibuka kembali.
- **Manajemen State Reaktif**: Menggunakan `Provider` (`ChangeNotifier`) untuk menangani siklus hidup tampilan (*Loading*, *Loaded*, *Empty*, dan *Error* dengan tombol *Coba Lagi*).
- **Pengaturan Satuan & Tema**: Mendukung konversi satuan suhu (°C / °F) langsung ke parameter API serta penyesuaian tema Material 3 (Sistem, Terang, Gelap).

---

## 2. Struktur Folder Proyek (MVVM Architecture)
```text
responsi_cuaca/
├── lib/
│   ├── main.dart                       # Entry point aplikasi, inisialisasi Storage & MultiProvider
│   ├── models/
│   │   ├── location.dart               # Model lokasi (Geocoding & Local Storage)
│   │   └── weather.dart                # Model data cuaca terkini & prakiraan harian
│   ├── services/
│   │   ├── weather_service.dart        # Service pemanggil HTTP GET Open-Meteo REST API
│   │   └── storage_service.dart        # Service pembaca & penyimpan SharedPreferences
│   ├── viewmodels/
│   │   ├── weather_viewmodel.dart      # ViewModel layar cuaca utama & kontrol status cuaca
│   │   ├── search_viewmodel.dart       # ViewModel pencarian kota & sinkronisasi API geocoding
│   │   ├── favorites_viewmodel.dart    # ViewModel manajemen data favorit & riwayat
│   │   └── settings_viewmodel.dart     # ViewModel manajemen satuan suhu & tema tampilan
│   ├── views/
│   │   ├── main_navigation_screen.dart # NavigationBar utama dengan 4 tab menu
│   │   ├── weather_screen.dart         # Layar tampilan cuaca terkini & ramalan 7 hari
│   │   ├── search_screen.dart          # Layar input pencarian kota & hasil dari API
│   │   ├── favorites_screen.dart       # Layar daftar favorit & riwayat pencarian
│   │   └── settings_screen.dart        # Layar preferensi suhu (°C/°F) & tema aplikasi
│   ├── utils/
│   │   └── weather_code.dart           # Konversi kode WMO ke teks Bahasa Indonesia & icon
│   └── theme/
│       └── app_theme.dart              # Konfigurasi terpusat ThemeData (Light & Dark)
├── ssan/                               # Folder tangkapan layar (screenshot aplikasi)
├── pubspec.yaml                        # Konfigurasi dependensi project Flutter
└── README.md                           # Dokumentasi teknis aplikasi
```

---

## 3. Penjelasan Implementasi API (Open-Meteo)

Aplikasi menggunakan dua endpoint utama dari REST API Open-Meteo tanpa hardcode data cuaca:

### a. Geocoding API (Pencarian Lokasi)
- **Endpoint**: `https://geocoding-api.open-meteo.com/v1/search`
- **Metode**: `HTTP GET`
- **Parameter**:
  - `name`: Nama kota yang dicari (contoh: `Semarang`, `Jakarta`).
  - `count`: Jumlah hasil maksimum (`10`).
  - `language`: Bahasa nama kota (`id` untuk Bahasa Indonesia).
- **Format URL**:
  `https://geocoding-api.open-meteo.com/v1/search?name={query}&count=10&language=id`

### b. Weather Forecast API (Prakiraan Cuaca)
- **Endpoint**: `https://api.open-meteo.com/v1/forecast`
- **Metode**: `HTTP GET`
- **Parameter Wajib yang Digunakan**:
  - `latitude`: Koordinat lintang kota.
  - `longitude`: Koordinat bujur lokasi kota.
  - `current`: `temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m`
  - `daily`: `weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max`
  - `timezone`: `auto`
  - `temperature_unit`: `celsius` atau `fahrenheit` (sesuai pengaturan pengguna).

### c. Tabel Pemetaan 9 Field API ke UI:
| No | Data Cuaca | Field API Open-Meteo | Komponen UI |
|---|---|---|---|
| 1 | Suhu saat ini | `current.temperature_2m` | Card Utama Cuaca Terkini |
| 2 | Kelembapan | `current.relative_humidity_2m` | Card Detail Kelembapan (%) |
| 3 | Suhu yang dirasakan | `current.apparent_temperature` | Card Detail "Terasa Seperti" |
| 4 | Curah hujan | `current.precipitation` | Card Detail Curah Hujan (mm) |
| 5 | Kode kondisi cuaca | `current.weather_code` | Ikon & Teks Cuaca (WMO) |
| 6 | Kecepatan angin | `current.wind_speed_10m` | Card Detail Kecepatan Angin (km/h) |
| 7 | Suhu maksimum harian | `daily.temperature_2m_max` | List Prakiraan 7 Hari |
| 8 | Suhu minimum harian | `daily.temperature_2m_min` | List Prakiraan 7 Hari |
| 9 | Peluang hujan maksimum | `daily.precipitation_probability_max`| List Prakiraan 7 Hari (%) |

---

## 4. Penjelasan Penerapan Pola Arsitektur MVVM
Arsitektur aplikasi secara tegas memisahkan tanggung jawab:
1. **Model (`lib/models/`)**:
   - `LocationModel` & `WeatherModel`: Mengubah payload JSON mentah dari HTTP Response menjadi entitas Dart yang strongly-typed dan null-safe.
2. **View (`lib/views/`)**:
   - Tidak pernah memanggil API atau `SharedPreferences` secara langsung.
   - Bersifat reaktif: Hanya menampilkan UI berdasarkan properti dari ViewModel dan memicu aksi pengguna melalui pemanggilan method ViewModel.
   - Menangani 3 kondisi utama di setiap screen yang berhubungan dengan API: **Loading**, **Data Kosong (Empty)**, dan **Error (dengan tombol Coba Lagi)**.
3. **ViewModel (`lib/viewmodels/`)**:
   - Mewarisi `ChangeNotifier` dari package Provider.
   - Mengelola state (status loading, error message, model data).
   - Menghubungkan View dengan Business Logic pada `WeatherService` dan `StorageService`.
   - Mengirim notifikasi perubahan data ke View melalui `notifyListeners()`.
4. **Service (`lib/services/`)**:
   - `WeatherService`: Menangani murni networking HTTP GET dan penanganan kegagalan koneksi (*SocketException*, *HttpException*).
   - `StorageService`: Menangani serialisasi dan persistensi lokal dengan `SharedPreferences`.

---

## 5. Cara Menjalankan Aplikasi
1. Pastikan Flutter SDK (versi stable) dan Android Studio / VS Code sudah terpasang.
2. Hubungkan perangkat HP Android fisik (aktifkan USB Debugging) atau jalankan Android Emulator.
3. Buka terminal di direktori proyek `D:\FlutterProjects\responsi_cuaca`:
   ```bash
   flutter pub get
   flutter run
   ```

---

## 6. Tangkapan Layar Aplikasi (Screenshots)
Simpan file tangkapan layar pada folder `ssan/` dengan format nama berikut:

| No | Nama Layar | File Screenshot |
|---|---|---|
| 1 | Weather Screen (Cuaca Terkini & Prakiraan) | `![Weather Screen](ssan/01_weather_screen.png)` |
| 2 | Weather Screen (Kondisi Error / Koneksi Mati) | `![Weather Error](ssan/02_weather_error.png)` |
| 3 | Search Screen (Input & Hasil Pencarian) | `![Search Screen](ssan/03_search_screen.png)` |
| 4 | Search Screen (Data Kosong / Tidak Ditemukan)| `![Search Empty](ssan/04_search_empty.png)` |
| 5 | Favorites Screen (Daftar Favorit & Riwayat) | `![Favorites Screen](ssan/05_favorites_screen.png)` |
| 6 | Settings Screen (Satuan Suhu & Tema) | `![Settings Screen](ssan/06_settings_screen.png)` |

---

## 7. Pengujian Mandiri
- **Pencarian Kota**: Masukkan "Bandung" pada tab Cari, pilih hasil pencarian, dan periksa apakah cuaca berpindah ke kota Bandung.
- **Favorit & Riwayat**: Tekan tombol hati, buka tab Favorit. Tutup aplikasi dan buka kembali; data favorit dan lokasi terakhir tetap tersimpan.
- **Penanganan Error**: Matikan koneksi WiFi/Data, lalu tekan tombol "Coba Lagi" untuk memverifikasi tampilan penanganan error.
- **Pencarian Kosong**: Ketik teks sembarang seperti "zzzxqw123" pada kolom pencarian untuk memverifikasi tampilan data kosong.
