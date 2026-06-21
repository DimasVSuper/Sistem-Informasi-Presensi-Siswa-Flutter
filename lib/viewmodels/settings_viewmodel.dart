import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isTestingConnection = false;
  int latency = -2;
  String savedUrl = '';

  Future<void> loadSettings() async {
    isLoading = true;
    notifyListeners();

    savedUrl = await StorageService.getBaseUrl();

    isLoading = false;
    notifyListeners();
  }

  // FUNGSI: Mengetes apakah alamat server yang baru dimasukkan itu bisa diakses
  Future<int> testConnection(String url) async {
    isTestingConnection = true; // Munculkan animasi loading tes
    latency = -2;
    notifyListeners();

    final normalizedUrl = url.trim();
    // 1. Ingat URL yang lama dulu
    final originalUrl = await StorageService.getBaseUrl();
    
    // 2. Simpan URL yang baru sementara
    await StorageService.saveBaseUrl(normalizedUrl);
    
    // 3. Coba kirim sinyal ke URL baru tersebut
    final result = await ApiService.pingServer();

    // 4. Kalau sudah selesai tes, kembalikan lagi URL-nya ke yang lama
    if (originalUrl != normalizedUrl) {
      await StorageService.saveBaseUrl(originalUrl);
    }

    latency = result; // Simpan hasil tes kecepatannya
    isTestingConnection = false; // Matikan animasi loading
    notifyListeners();

    return result;
  }

  Future<bool> saveSettings(String url) async {
    isLoading = true;
    notifyListeners();

    final normalizedUrl = url.trim();
    final success = await StorageService.saveBaseUrl(normalizedUrl);
    if (success) {
      savedUrl = normalizedUrl;
    }

    isLoading = false;
    notifyListeners();

    return success;
  }

  Future<bool> clearLogs() async {
    isLoading = true;
    notifyListeners();

    final success = await StorageService.clearLogs();

    isLoading = false;
    notifyListeners();

    return success;
  }
}
