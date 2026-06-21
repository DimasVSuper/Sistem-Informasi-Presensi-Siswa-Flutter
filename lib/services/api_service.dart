import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'storage_service.dart';

class ApiService {
  // FUNGSI: Tes koneksi ke server, apakah nyambung atau tidak (seperti panggil "Halo" ke teman)
  // Balasannya angka (ms) kalau nyambung, -1 kalau gagal.
  static Future<int> pingServer() async {
    final baseUrl = await StorageService.getBaseUrl();
    final url = Uri.parse(baseUrl);

    final stopwatch = Stopwatch()..start(); // Mulai menghitung waktu
    try {
      // Coba akses alamat server. Maksimal nunggu 4 detik.
      await http.get(url).timeout(const Duration(seconds: 4));
      stopwatch.stop(); // Matikan hitungan waktu
      return stopwatch.elapsedMilliseconds; // Kembalikan waktu respon
    } catch (e) {
      stopwatch.stop();
      return -1; // Kalau error / server mati, beri nilai -1
    }
  }

  // FUNGSI: Mengirim data kode QR ke website/server untuk dicatat absennya
  static Future<ApiResponse> submitAttendance(String qrCode) async {
    try {
      // 1. Ambil alamat server
      final baseUrl = await StorageService.getBaseUrl();
      final url = Uri.parse('$baseUrl/presensi');

      // 2. Siapkan format pesannya (Format JSON/seperti kamus)
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Bungkus QR Codenya ke paket pesanan
      final body = json.encode({'qr_code': qrCode});

      // 3. Kirim via jalur HTTP POST, tunggu paling lama 7 detik
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 7));

      // Buka balasan/jawaban dari server
      final Map<String, dynamic> responseData = json.decode(response.body);
      final int statusCode = response.statusCode; // 201 = Sukses, 404 = Gagal

      if (statusCode == 201) {
        // JIKA SUKSES (Data tersimpan di server)
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
        // JIKA SUDAH ABSEN (Dobel)
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
        // JIKA QR CODE TIDAK ADA DI DATABASE
        return ApiResponse(
          isSuccess: false,
          statusCode: statusCode,
          message:
              responseData['message'] ??
              'Siswa tidak ditemukan. QR Code tidak valid.',
          status: 'Tidak Dikenal',
        );
      } else {
        // JIKA ERROR LAINNYA DARI SERVER
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
