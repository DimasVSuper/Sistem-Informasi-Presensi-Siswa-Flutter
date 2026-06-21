import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_log.dart';

class StorageService {
  static const String _keyBaseUrl = 'api_base_url';
  static const String _keyLogs = 'attendance_scan_logs';
  static const String _defaultUrl = 'http://10.0.2.2:8000/api'; // Android Emulator default for localhost

  // FUNGSI: Mengambil alamat server yang tersimpan di HP.
  // Kalau belum pernah disimpan, pakai alamat bawaan (localhost).
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBaseUrl) ?? _defaultUrl;
  }

  // FUNGSI: Menyimpan alamat server baru ke dalam HP.
  static Future<bool> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    // Rapikan URL: buang tanda garis miring di belakang jika ada
    String normalized = url.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return prefs.setString(_keyBaseUrl, normalized);
  }

  // FUNGSI: Mengambil semua riwayat absen yang tersimpan di HP.
  // Urutannya dibalik agar yang terbaru muncul paling atas.
  static Future<List<AttendanceLog>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_keyLogs);
    if (jsonList == null) return [];

    try {
      return jsonList
          .map((item) => AttendanceLog.fromJson(json.decode(item)))
          .toList()
          .reversed // Menampilkan yang paling baru di atas
          .toList();
    } catch (e) {
      // Jika data rusak, kembalikan kosong
      return [];
    }
  }

  // FUNGSI: Menambahkan 1 catatan absen baru ke dalam memori HP.
  static Future<void> addLog(AttendanceLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_keyLogs) ?? [];
    
    // Tambahkan riwayat baru ke urutan paling belakang
    jsonList.add(json.encode(log.toJson()));

    // Jangan simpan terlalu banyak agar HP tidak lemot, batasi 200 data terakhir saja
    if (jsonList.length > 200) {
      jsonList.removeRange(0, jsonList.length - 200);
    }

    await prefs.setStringList(_keyLogs, jsonList);
  }

  // Clear all cached logs
  static Future<bool> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_keyLogs);
  }
}
