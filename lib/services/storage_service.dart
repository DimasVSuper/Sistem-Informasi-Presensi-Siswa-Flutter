import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_log.dart';

class StorageService {
  static const String _keyBaseUrl = 'api_base_url';
  static const String _keyLogs = 'attendance_scan_logs';
  static const String _defaultUrl = 'http://10.0.2.2:8000/api'; // Android Emulator default for localhost

  // Get Saved Base API URL
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBaseUrl) ?? _defaultUrl;
  }

  // Save new Base API URL
  static Future<bool> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    // Normalize URL: remove trailing slash if any
    String normalized = url.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return prefs.setString(_keyBaseUrl, normalized);
  }

  // Get all logs (newest first)
  static Future<List<AttendanceLog>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_keyLogs);
    if (jsonList == null) return [];

    try {
      return jsonList
          .map((item) => AttendanceLog.fromJson(json.decode(item)))
          .toList()
          .reversed // Showing newest first
          .toList();
    } catch (e) {
      // If corrupted, return empty
      return [];
    }
  }

  // Add a single log entry
  static Future<void> addLog(AttendanceLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_keyLogs) ?? [];
    
    // Add new log to the end
    jsonList.add(json.encode(log.toJson()));

    // Keep log history reasonable, say last 200 scans
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
