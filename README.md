# PresensiGo (Mobile Version)

Aplikasi mobile Flutter untuk memindai QR Code presensi siswa dan menyimpan hasil scan secara lokal. Aplikasi ini juga berkomunikasi dengan backend Laravel untuk mencatat presensi, memeriksa status siswa, dan memberi umpan balik hasil scan.

Inspirasi backend berasal dari: https://github.com/DimasVSuper/Sistem-Informasi-Presensi-Siswa-Laravel-11

## Fitur Utama

- Memindai QR Code siswa menggunakan kamera perangkat
- Mengirim data presensi ke endpoint Laravel `POST /api/presensi`
- Menampilkan hasil scan real-time dengan status sukses, duplikat, atau gagal
- Menyimpan riwayat scan lokal menggunakan `shared_preferences`
- Mengelola konfigurasi endpoint API dari layar pengaturan
- Struktur aplikasi MVVM dengan `viewmodels`, `models`, `services`, dan `screens`

## Struktur Proyek

- `lib/main.dart` - Entry point aplikasi
- `lib/screens/` - UI screen untuk dashboard, scanner, dan pengaturan
- `lib/viewmodels/` - ViewModels yang memisahkan state dan logika bisnis dari UI
- `lib/models/` - Model data seperti `AttendanceLog` dan `ApiResponse`
- `lib/services/` - Layanan API dan storage
- `lib/widgets/` - Widget khusus seperti overlay scanner

## Persyaratan

- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code dengan plugin Flutter

## Setup dan Jalankan

1. Pasang dependency:

```bash
flutter pub get
```

2. Jalankan aplikasi di emulator atau perangkat fisik:

```bash
flutter run
```

3. Analisis kode untuk memastikan tidak ada masalah:

```bash
flutter analyze
```

## Konfigurasi API

Aplikasi menggunakan `SharedPreferences` untuk menyimpan endpoint API. Buka menu Pengaturan, lalu masukkan base URL Laravel API, misalnya:

```text
http://192.168.1.100:8000/api
```

Setelah menyimpan URL, gunakan tombol `Tes Koneksi` untuk memastikan aplikasi dapat terhubung ke backend.

## Catatan Penting

- Default URL untuk emulator Android adalah `http://10.0.2.2:8000/api`
- Riwayat scan disimpan secara lokal dan dapat dihapus dari layar pengaturan
- Rendering dan state management sudah dipisahkan dalam pola MVVM untuk memudahkan pemeliharaan

## Lisensi

Proyek ini adalah contoh aplikasi dan dapat dikembangkan lebih lanjut sesuai kebutuhan.
