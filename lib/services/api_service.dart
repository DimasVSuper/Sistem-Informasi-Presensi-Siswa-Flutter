import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'storage_service.dart';

class ApiService {
  // Test connection to the configured backend URL
  // Returns latency in milliseconds, or -1 if unreachable
  static Future<int> pingServer() async {
    final baseUrl = await StorageService.getBaseUrl();
    final url = Uri.parse(baseUrl);

    final stopwatch = Stopwatch()..start();
    try {
      // Just hit the base URL, or a subpath. Even if it returns 404 or 405,
      // as long as the server responds, it means the connection is active.
      await http.get(url).timeout(const Duration(seconds: 4));
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      stopwatch.stop();
      return -1; // Unreachable
    }
  }

  // Submit QR code attendance scan to Laravel backend
  static Future<ApiResponse> submitAttendance(String qrCode) async {
    try {
      final baseUrl = await StorageService.getBaseUrl();
      final url = Uri.parse('$baseUrl/presensi');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = json.encode({'qr_code': qrCode});

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 7));

      final Map<String, dynamic> responseData = json.decode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 201) {
        // Success
        final data = responseData['data'] ?? {};
        return ApiResponse(
          isSuccess: true,
          statusCode: statusCode,
          message: responseData['message'] ?? 'Presensi berhasil dicatat.',
          studentName: data['nama'] ?? 'Siswa',
          nis: data['nis'] ?? '',
          date: data['tanggal'] ?? '',
          time: data['waktu'] ?? '',
          status: data['status'] ?? 'Hadir',
        );
      } else if (statusCode == 409) {
        // Already scanned today
        final data = responseData['data'] ?? {};
        return ApiResponse(
          isSuccess: false,
          statusCode: statusCode,
          message:
              responseData['message'] ??
              'Siswa sudah melakukan presensi hari ini.',
          studentName: data['nama'] ?? 'Siswa',
          nis: data['nis'] ?? '',
          status: 'Sudah Hadir',
        );
      } else if (statusCode == 404) {
        // Student / QR not found
        return ApiResponse(
          isSuccess: false,
          statusCode: statusCode,
          message:
              responseData['message'] ??
              'Siswa tidak ditemukan. QR Code tidak valid.',
          status: 'Tidak Dikenal',
        );
      } else {
        // General error response
        return ApiResponse(
          isSuccess: false,
          statusCode: statusCode,
          message:
              responseData['message'] ??
              'Terjadi kesalahan server (${response.statusCode})',
          status: 'Error',
        );
      }
    } on SocketException {
      return ApiResponse(
        isSuccess: false,
        statusCode: 503,
        message:
            'Gagal terhubung ke server. Periksa jaringan Anda atau konfigurasi IP.',
        status: 'Error Koneksi',
      );
    } on HttpException {
      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Protokol komunikasi salah atau server menolak koneksi.',
        status: 'Error HTTP',
      );
    } on FormatException {
      return ApiResponse(
        isSuccess: false,
        statusCode: 422,
        message: 'Format respon dari server tidak valid (Bukan JSON).',
        status: 'Error Format',
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Terjadi masalah: ${e.toString()}',
        status: 'Error',
      );
    }
  }
}
