# 📘 Buku Saku / Contekan Presentasi Aplikasi Presensi (MVVM)

Dokumen ini dibuat khusus untuk membantu anggota tim (terutama yang non-programmer) dalam menjelaskan aplikasi saat presentasi atau demo kepada dosen/penguji.

---

## 🏢 Analogi "Restoran" untuk Menjelaskan MVVM
Jika ditanya: *"Aplikasi ini pakai struktur atau arsitektur apa? Coba jelaskan!"*
**Jawab:** "Aplikasi kami menggunakan arsitektur **MVVM (Model - View - ViewModel)**. Agar mudah dibayangkan, ibaratkan sebuah **Restoran**:"

1. **View (`screens/` & `widgets/`) = Buku Menu & Meja Makan**
   Ini adalah tampilan fisik aplikasi yang dilihat pengguna (tombol, teks, kamera). *Contoh: `dashboard_screen.dart` (halaman depan) dan `scanner_screen.dart` (layar kamera).*
2. **ViewModel (`viewmodels/`) = Pelayan**
   Tugasnya menerima pesanan dari View. Kalau tombol "Scan" ditekan, Pelayan (ViewModel) yang akan memproses permintaannya dan memastikan UI (layar) terupdate. *Contoh: `scanner_viewmodel.dart`.*
3. **Model (`models/`) = Bahan Makanan / Resep Baku**
   Ini adalah format data baku. *Contoh: `attendance_log.dart` yang mengatur format bahwa setiap absen harus ada "Jam, Nama, NIS, dan Status".*
4. **Service (`services/`) = Koki di Dapur**
   Ini adalah bagian yang bekerja di belakang layar untuk berkomunikasi dengan Server (Database). *Contoh: `api_service.dart` yang bertugas mengirim pesan "Siswa A hadir" ke server lewat internet.*

---

## ❓ Pertanyaan yang Sering Muncul & Cara Menjawabnya

### Q1: "Coba jelaskan bagaimana alur saat QR Code discan sampai muncul di layar utama?"
**Jawaban (Hafalkan alur ini):**
1. **View (Kamera)** membaca kotak QR Code.
2. Kode tersebut langsung dikirim ke **ScannerViewModel** (Pelayan).
3. ViewModel menyuruh **ApiService** (Koki) mengirim kode tersebut ke Website/Server lewat jalur internet.
4. Jika server merespon "Berhasil", ViewModel akan mencatat data tersebut ke memori HP.
5. Selesai! Layar kembali siap untuk scan kode berikutnya.

### Q2: "Coba tunjukkan di mana kode yang bertugas ngecek apakah servernya hidup atau mati?"
**Jawaban:** "Ada di file `dashboard_viewmodel.dart` di fungsi `checkServerConnection()`. Di situ kami melakukan semacam 'Ping' ke server. Kalau ada balasan angka (milidetik), berarti nyala. Kalau -1 berarti mati/gagal."
*(Buka file tersebut, baca komentar bahasa Indonesianya!)*

### Q3: "Bagaimana aplikasi ini membedakan siswa yang sukses absen dengan yang absen dobel?"
**Jawaban:** "Logikanya ada di `dashboard_viewmodel.dart` pada fungsi `_updateStats()`. Kami mengecek balasan dari server. Jika status dari server adalah 201, masuk ke hitungan Sukses. Jika statusnya 409 (Pesan: 'Sudah Hadir'), maka akan masuk ke hitungan Dobel."

### Q4: "Kode yang mengirim data ke backend (Laravel) pakai apa?"
**Jawaban:** "Kami menggunakan **http post** yang ada di file `api_service.dart`. Kami mengambil URL dari memori, membungkus QR code dalam format JSON, lalu mengirimnya ke endpoint `/presensi`. Kami juga set batas waktu maksimal (timeout) 7 detik agar tidak loading selamanya kalau sinyal jelek."
*(Buka file tersebut, baca komentar bahasa Indonesianya!)*

---

## 💡 Tips Rahasia Saat Live Coding / Demo
* **Jangan Panik saat Ditanya Baris Kode:** Saya sudah menambahkan **Komentar Bahasa Indonesia (warna hijau)** di file-file utama (`dashboard_viewmodel.dart`, `scanner_viewmodel.dart`, dan `api_service.dart`).
* **Cara Ngeles yang Elegan:** Kalau dosen menunjuk baris kode yang kamu benar-benar lupa fungsinya, kamu tinggal **BACA KOMENTAR HIJAU** tepat di atas baris tersebut dengan percaya diri!
