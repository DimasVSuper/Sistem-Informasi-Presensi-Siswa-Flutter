# Panduan Konfigurasi Koneksi API (Laravel ↔ Flutter)

Dokumen ini menjelaskan langkah-langkah untuk menghubungkan aplikasi Flutter Attendance Scanner dengan backend Laravel 11.

---

## Persiapan Awal di Server Laravel

Pastikan server Laravel Anda sudah berjalan sebelum menghubungkan aplikasi Flutter. Jalankan perintah berikut di terminal proyek Laravel Anda:

```bash
php artisan serve
```

Secara default, Laravel akan berjalan di alamat `http://127.0.0.1:8000` atau `http://localhost:8000`.

---

## Opsi 1: Emulator Android di Laptop yang Sama

Jika aplikasi Flutter dijalankan pada emulator Android yang berada di laptop yang sama dengan server Laravel, gunakan alamat berikut:

```text
http://10.0.2.2:8000/api
```

Alamat ini bekerja karena emulator Android memetakan `localhost` komputer ke `10.0.2.2`.

---

## Opsi 2: HP Fisik dan Jaringan Lokal yang Sama

Untuk pengujian menggunakan perangkat fisik, pastikan HP dan laptop terhubung ke jaringan Wi-Fi yang sama atau hotspot yang sama.

### Langkah

1.  Temukan IP lokal laptop Anda:
    - Windows: buka `cmd`, jalankan `ipconfig`, lalu cari `IPv4 Address`
    - Mac/Linux: jalankan `ifconfig` atau `ip a`
2.  Jalankan Laravel agar menerima koneksi dari jaringan lokal:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

3.  Masukkan URL berikut di aplikasi Flutter:

```text
http://<IP_LOKAL_LAPTOP>:8000/api
```

Contoh:

```text
http://192.168.1.15:8000/api
```

### Catatan

Beberapa jaringan publik dapat memblokir komunikasi antar perangkat (client isolation). Jika koneksi gagal, gunakan opsi Ngrok atau hotspot lainnya.

---

## Opsi 3: Ngrok untuk Akses Publik

Jika HP dan laptop tidak berada di jaringan yang sama, atau jika jaringan lokal membatasi koneksi, gunakan Ngrok.

### Langkah

1.  Install Ngrok dari https://ngrok.com.
2.  Pastikan Laravel berjalan di port 8000.
3.  Jalankan:

```bash
ngrok http 8000
```

4.  Ngrok akan menampilkan URL publik, misalnya:

```text
https://a1b2-34-56-78.ngrok-free.app
```

5.  Masukkan URL berikut di aplikasi Flutter:

```text
https://<KODE_NGROK>.ngrok-free.app/api
```

---

## Cara Mengubah URL di Aplikasi Flutter

1.  Buka aplikasi di emulator atau perangkat fisik.
2.  Buka halaman Dashboard.
3.  Ketuk tombol Pengaturan.
4.  Masukkan alamat Laravel API di bidang `Laravel API Base URL`.
5.  Ketuk tombol `Tes Koneksi` untuk memvalidasi koneksi.
6.  Ketuk tombol `Simpan URL`.
7.  Kembali ke Dashboard dan mulai memindai QR Code.

---

## Tips

- Gunakan `http://10.0.2.2:8000/api` untuk emulator Android.
- Gunakan `http://<IP_LOKAL>:8000/api` untuk perangkat fisik di jaringan lokal.
- Gunakan `https://<KODE_NGROK>.ngrok-free.app/api` untuk akses lintas jaringan.
- Pastikan `php artisan serve` aktif selama pengujian.
