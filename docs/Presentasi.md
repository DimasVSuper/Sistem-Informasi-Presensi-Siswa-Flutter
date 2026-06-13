# Presentasi Proyek PresensiGo (Mobile Version)

## Slide 1 — Judul
PresensiGo (Mobile Version)

Aplikasi mobile Flutter untuk presensi siswa berbasis QR Code yang terhubung ke backend Laravel.

---

## Slide 2 — Latar Belakang
- Presensi manual sering memakan waktu dan rawan kesalahan.
- Diperlukan solusi mobile yang cepat, praktis, dan terintegrasi dengan sistem backend.
- Proyek ini merupakan versi mobile dari sistem presensi berbasis web Laravel.

---

## Slide 3 — Tujuan Proyek
- Mempermudah proses absensi siswa melalui scan QR Code.
- Mengurangi kesalahan input manual.
- Menyediakan riwayat scan lokal serta sinkronisasi ke backend.

---

## Slide 4 — Fitur Utama
- Scan QR Code siswa menggunakan kamera.
- Pengiriman data presensi ke API Laravel.
- Status hasil scan: sukses, duplikat, atau gagal.
- Penyimpanan riwayat scan lokal.
- Pengaturan endpoint API melalui menu settings.

---

## Slide 5 — Arsitektur Aplikasi
- lib/main.dart : entry point aplikasi.
- lib/screens/ : tampilan dashboard, scanner, dan settings.
- lib/viewmodels/ : logika state dan bisnis.
- lib/services/ : koneksi API dan penyimpanan data.
- lib/models/ : model data presensi dan response API.

---

## Slide 6 — Alur Kerja Aplikasi
1. Pengguna membuka menu scanner.
2. Aplikasi memindai QR Code siswa.
3. Data dikirim ke backend Laravel melalui API.
4. Hasil respon ditampilkan ke pengguna.
5. Riwayat scan disimpan lokal untuk referensi.

---

## Slide 7 — Teknologi yang Digunakan
- Flutter
- Dart
- mobile_scanner
- shared_preferences
- HTTP / API integration
- MVVM architecture

---

## Slide 8 — Keunggulan Proyek
- Cepat dan praktis untuk penggunaan di lapangan.
- Mudah dikembangkan dan dipelihara.
- Terstruktur dengan pola MVVM.
- Bisa digunakan bersama backend Laravel yang sudah ada.

---

## Slide 9 — Kesimpulan
PresensiGo (Mobile Version) adalah solusi mobile presensi berbasis QR Code yang modern, efisien, dan siap dikembangkan lebih lanjut untuk kebutuhan sekolah atau instansi.

---

## Slide 10 — Penutup
Terima kasih.

Jika diperlukan, presentasi ini dapat diperluas menjadi versi lebih formal, lebih singkat, atau disesuaikan untuk demo live.
