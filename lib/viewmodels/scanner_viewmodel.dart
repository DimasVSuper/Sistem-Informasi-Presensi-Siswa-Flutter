import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/attendance_log.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ScannerViewModel extends ChangeNotifier {
  bool isProcessing = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;

  // FUNGSI: Menangani kode yang baru saja berhasil discan kamera
  Future<ApiResponse> processQrCode(String qrCode) async {
    isProcessing = true; // Tahan kamera agar tidak scan terus menerus
    notifyListeners();

    // 1. Kirim kode hasil scan ke server (ke Tukang / API Service)
    final response = await ApiService.submitAttendance(qrCode);

    // 2. Buat catatan riwayat lokal
    final log = AttendanceLog(
      qrCode: qrCode,
      studentName: response.studentName.isNotEmpty
          ? response.studentName
          : 'Siswa',
      nis: response.nis,
      scannedAt: DateTime.now(), // Jam waktu di-scan
      isSuccess: response.isSuccess,
      status: response.status,
      message: response.message,
    );

    // 3. Simpan riwayat tersebut ke dalam memori HP
    await StorageService.addLog(log);

    isProcessing = false; // Boleh scan lagi
    notifyListeners();
    return response; // Kembalikan jawaban dari server (berhasil/gagal)
  }

  void setProcessing(bool value) {
    isProcessing = value;
    notifyListeners();
  }

  void setFlashOn(bool value) {
    isFlashOn = value;
    notifyListeners();
  }

  void setFrontCamera(bool value) {
    isFrontCamera = value;
    notifyListeners();
  }
}
