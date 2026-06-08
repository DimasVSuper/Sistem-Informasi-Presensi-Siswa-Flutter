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

  Future<int> testConnection(String url) async {
    isTestingConnection = true;
    latency = -2;
    notifyListeners();

    final normalizedUrl = url.trim();
    final originalUrl = await StorageService.getBaseUrl();
    await StorageService.saveBaseUrl(normalizedUrl);
    final result = await ApiService.pingServer();

    if (originalUrl != normalizedUrl) {
      await StorageService.saveBaseUrl(originalUrl);
    }

    latency = result;
    isTestingConnection = false;
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
