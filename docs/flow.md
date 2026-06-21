# 🔄 Alur Kerja Aplikasi (Workflow)

Dokumen ini menjelaskan secara teknis bagaimana aplikasi bekerja dari awal dibuka hingga selesai melakukan scan presensi. Dokumen ini sangat berguna untuk menjelaskan "Di mana kode X berjalan?" saat ditanya oleh dosen atau penguji.

---

## 1. Aplikasi Dibuka (Entry Point)
Saat ikon aplikasi ditekan di HP, kode pertama yang dijalankan ada di `main.dart`.
* **Nama File:** `lib/main.dart`
* **Koding Utama:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const AttendanceScannerApp()); // Menjalankan aplikasi
}
```
* **Penjelasan:** Sistem flutter disiapkan, format tanggal Indonesia diaktifkan, lalu aplikasi memuat tema warna (gelap/terang) dan langsung mengarahkan pengguna ke halaman `DashboardScreen`.

---

## 2. Halaman Utama Memuat Data (Dashboard)
Saat halaman utama terbuka, layar akan meminta "Pelayan" (ViewModel) untuk mengambil data dari memori HP dan mengecek apakah server aktif.
* **Nama File UI:** `lib/screens/dashboard_screen.dart`
* **Koding UI:**
```dart
  @override
  void initState() {
    super.initState();
    // Meminta viewmodel untuk langsung memuat data saat layar dibuka
    _viewModel = DashboardViewModel()..loadDashboardData();
  }
```
* **Nama File Logika:** `lib/viewmodels/dashboard_viewmodel.dart`
* **Koding Logika:**
```dart
  Future<void> loadDashboardData() async {
    isLoading = true; 
    notifyListeners(); // Update layar memunculkan animasi muter-muter

    // Ambil data riwayat lokal dan URL server
    final fetchedLogs = await StorageService.getLogs();
    final fetchedUrl = await StorageService.getBaseUrl();
    
    // ... proses hitung statistik ...
    
    await checkServerConnection(); // Tes ping server
  }
```

---

## 3. Kamera Menangkap QR Code (Scanner)
Pengguna menekan tombol Scan, layar berubah menjadi kamera. Saat kotak QR Code masuk ke layar, kamera otomatis mendeteksinya.
* **Nama File:** `lib/screens/scanner_screen.dart`
* **Koding Utama:**
```dart
  // Fungsi yang otomatis terpanggil saat kamera melihat QR Code
  void _onDetect(BarcodeCapture capture) {
    if (_viewModel.isProcessing) return; // Jangan scan dobel

    final String? qrCode = capture.barcodes.first.rawValue;
    if (qrCode == null || qrCode.trim().isEmpty) return;

    HapticFeedback.vibrate(); // Getarkan HP
    _processQrCode(qrCode);   // Lanjut ke proses kirim data
  }
```

---

## 4. Mengirim Data ke Server (API Request)
Kode QR yang didapat dari kamera diserahkan ke ViewModel, lalu ViewModel menyuruh `ApiService` untuk mengirimkannya via internet ke website Laravel.
* **Nama File Logika:** `lib/viewmodels/scanner_viewmodel.dart`
* **Koding Logika:**
```dart
  Future<ApiResponse> processQrCode(String qrCode) async {
    isProcessing = true;
    notifyListeners();

    // 1. Minta API Service ngirim kode ke server
    final response = await ApiService.submitAttendance(qrCode);
    // ...
```
* **Nama File Jaringan:** `lib/services/api_service.dart`
* **Koding Jaringan:**
```dart
  static Future<ApiResponse> submitAttendance(String qrCode) async {
    final url = Uri.parse('$baseUrl/presensi');
    final body = json.encode({'qr_code': qrCode});

    // Melakukan HTTP POST request ke server Laravel
    final response = await http.post(url, headers: headers, body: body)
                               .timeout(const Duration(seconds: 7));
                               
    // Setelah dapat balasan, ubah format JSON menjadi objek ApiResponse
    // Jika 201 = Sukses, Jika 409 = Sudah Hadir, Jika 404 = Gagal
  }
```

---

## 5. Menyimpan Riwayat & Menampilkan Hasil
Setelah server memberikan balasan (baik itu sukses, duplikat, atau gagal), aplikasi akan mencatat kejadian tersebut ke memori HP, lalu menampilkan Pop-up dari bawah layar.
* **Nama File Simpan Lokal:** `lib/services/storage_service.dart`
* **Koding Simpan Lokal:**
```dart
  static Future<void> addLog(AttendanceLog log) async {
    // ... ambil data lama ...
    jsonList.add(json.encode(log.toJson())); // Tambah data baru
    await prefs.setStringList(_keyLogs, jsonList); // Simpan kembali ke HP
  }
```
* **Nama File Pop-up UI:** `lib/screens/scanner_screen.dart`
* **Koding Pop-up:**
```dart
  void _showResultBottomSheet(ApiResponse response, String qrCode) {
    // Membuka modal pop up dari bawah layar berdasarkan response API
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // ... kode desain pop up centang hijau / silang merah ...
      }
    );
  }
```

---

## 6. (Tambahan Khusus) Animasi Garis Scanner Kosmetik
Di atas kamera yang sedang menyorot QR Code, ada kotak dan animasi garis laser yang bergerak naik-turun. Ini tidak mempengaruhi pembacaan QR Code (pembacaan murni oleh kamera), ini murni hiasan agar terlihat keren.
* **Nama File UI:** `lib/widgets/scanner_overlay.dart`
* **Koding Gambar:**
```dart
  void paint(Canvas canvas, Size size) {
    // 1. Menggambar area luar kotak menjadi gelap (overlay)
    // 2. Menggambar 4 sudut siku menyala bergaya Sci-Fi
    // 3. Menggambar garis laser yang posisinya (sumbu Y) naik turun 
    //    mengikuti hitungan animasi (_animationController)
    // 4. Menambahkan bayangan gradasi (glow) pada garis laser
  }
```
