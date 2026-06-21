import 'package:flutter/foundation.dart';
import '../models/attendance_log.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DashboardViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isCheckingServer = false;
  bool isServerOnline = false;
  int serverLatency = -1;
  String serverUrl = '';
  List<AttendanceLog> logs = [];
  int successCount = 0;
  int duplicateCount = 0;
  int failedCount = 0;

  int get totalScans => successCount + duplicateCount + failedCount;

  // FUNGSI: Mengambil data absensi dari HP untuk ditampilkan di layar utama
  Future<void> loadDashboardData() async {
    isLoading = true; // 1. Tampilkan animasi muter-muter (loading) di layar
    notifyListeners(); // Kasih tau layar supaya update tampilannya

    // 2. Ambil data riwayat yang tersimpan di HP
    final fetchedLogs = await StorageService.getLogs();
    // 3. Ambil alamat server (URL) dari pengaturan
    final fetchedUrl = await StorageService.getBaseUrl();

    // 4. Hitung statistik hari ini (berapa yang sukses, gagal, dll)
    _updateStats(fetchedLogs);
    serverUrl = fetchedUrl; // Simpan URL untuk ditampilkan
    isLoading = false; // 5. Matikan animasi loading
    notifyListeners(); // Update layar lagi

    // 6. Cek apakah server nyala atau mati
    await checkServerConnection();
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  // FUNGSI: Mengecek apakah HP bisa connect ke server (tes sinyal)
  Future<void> checkServerConnection() async {
    // Kalau masih ngecek, jangan lakukan apa-apa
    if (isCheckingServer) return;

    isCheckingServer = true; // Mulai ngecek
    notifyListeners();

    // Lakukan 'ping' (tes sinyal) ke server
    final latency = await ApiService.pingServer();

    serverLatency = latency; // Simpan angka kecepatan (ms)
    isServerOnline = latency >= 0; // Kalau hasilnya >= 0 berarti nyala
    isCheckingServer = false; // Selesai ngecek
    notifyListeners(); // Update layar dengan hasil tes
  }

  // FUNGSI: Menghitung berapa banyak siswa yang sukses absen hari ini
  void _updateStats(List<AttendanceLog> fetchedLogs) {
    logs = fetchedLogs;
    successCount = 0; // Reset hitungan sukses
    duplicateCount = 0; // Reset hitungan dobel
    failedCount = 0; // Reset hitungan gagal

    final now = DateTime.now(); // Ambil waktu sekarang
    
    // Saring data, ambil yang hari ini saja
    final todayLogs = logs.where((log) {
      return log.scannedAt.year == now.year &&
          log.scannedAt.month == now.month &&
          log.scannedAt.day == now.day;
    });

    // Hitung satu-satu
    for (final log in todayLogs) {
      if (log.isSuccess) {
        successCount++; // Jika berhasil, tambah 1 ke sukses
      } else if (log.status == 'Sudah Hadir' ||
          log.message.contains('sudah melakukan presensi')) {
        duplicateCount++; // Jika pesan bilang sudah hadir, tambah dobel
      } else {
        failedCount++; // Sisanya masuk gagal
      }
    }
  }
}
