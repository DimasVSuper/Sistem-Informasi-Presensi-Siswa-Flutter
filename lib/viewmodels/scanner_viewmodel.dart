import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/attendance_log.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ScannerViewModel extends ChangeNotifier {
  bool isProcessing = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;

  Future<ApiResponse> processQrCode(String qrCode) async {
    isProcessing = true;
    notifyListeners();

    final response = await ApiService.submitAttendance(qrCode);

    final log = AttendanceLog(
      qrCode: qrCode,
      studentName: response.studentName.isNotEmpty
          ? response.studentName
          : 'Siswa',
      nis: response.nis,
      scannedAt: DateTime.now(),
      isSuccess: response.isSuccess,
      status: response.status,
      message: response.message,
    );

    await StorageService.addLog(log);

    isProcessing = false;
    notifyListeners();
    return response;
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
