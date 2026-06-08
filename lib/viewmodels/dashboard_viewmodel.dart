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

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    final fetchedLogs = await StorageService.getLogs();
    final fetchedUrl = await StorageService.getBaseUrl();

    _updateStats(fetchedLogs);
    serverUrl = fetchedUrl;
    isLoading = false;
    notifyListeners();

    await checkServerConnection();
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  Future<void> checkServerConnection() async {
    if (isCheckingServer) return;

    isCheckingServer = true;
    notifyListeners();

    final latency = await ApiService.pingServer();

    serverLatency = latency;
    isServerOnline = latency >= 0;
    isCheckingServer = false;
    notifyListeners();
  }

  void _updateStats(List<AttendanceLog> fetchedLogs) {
    logs = fetchedLogs;
    successCount = 0;
    duplicateCount = 0;
    failedCount = 0;

    final now = DateTime.now();
    final todayLogs = logs.where((log) {
      return log.scannedAt.year == now.year &&
          log.scannedAt.month == now.month &&
          log.scannedAt.day == now.day;
    });

    for (final log in todayLogs) {
      if (log.isSuccess) {
        successCount++;
      } else if (log.status == 'Sudah Hadir' ||
          log.message.contains('sudah melakukan presensi')) {
        duplicateCount++;
      } else {
        failedCount++;
      }
    }
  }
}
