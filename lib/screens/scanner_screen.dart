import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import '../models/api_response.dart';
import '../viewmodels/scanner_viewmodel.dart';
import '../widgets/scanner_overlay.dart';

// FUNGSI: Ini adalah HALAMAN KAMERA (Scanner).
// Tempat pengguna mengarahkan HP ke kartu QR siswa.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  late final ScannerViewModel _viewModel;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ScannerViewModel();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // FUNGSI: Otomatis terpanggil kalau kamera berhasil mendeteksi/menangkap QR Code
  void _onDetect(BarcodeCapture capture) {
    if (_viewModel.isProcessing) return; // Jangan scan berulang-ulang kalau masih proses

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrCode = barcodes.first.rawValue;
    if (qrCode == null || qrCode.trim().isEmpty) return;

    HapticFeedback.vibrate(); // HP getar sedikit menandakan sukses scan
    _processQrCode(qrCode); // Lanjut ke proses pengiriman data
  }

  Future<void> _processQrCode(String qrCode) async {
    final ApiResponse response = await _viewModel.processQrCode(qrCode);
    if (mounted) {
      _showResultBottomSheet(response, qrCode);
    }
  }

  // FUNGSI: Menampilkan jendela pop-up hasil dari bawah layar (Sukses/Gagal)
  void _showResultBottomSheet(ApiResponse response, String qrCode) {
    Color primaryColor;
    IconData statusIcon;
    String statusTitle;

    if (response.isSuccess) {
      primaryColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle_outline_rounded;
      statusTitle = 'Absen berhasil!';
    } else if (response.statusCode == 409) {
      primaryColor = Colors.amber.shade600;
      statusIcon = Icons.info_outline_rounded;
      statusTitle = 'Anda sudah Absen! tidak perlu Scan QR code lagi';
    } else {
      primaryColor = Colors.redAccent;
      statusIcon = Icons.cancel_outlined;
      statusTitle = 'Mohon maaf ada yang salah, silahkan coba lagi';
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return PopScope(
          canPop: false,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(statusIcon, color: primaryColor, size: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    response.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Divider(height: 1),
                  ),
                  if (response.studentName.isNotEmpty ||
                      response.nis.isNotEmpty) ...[
                    _buildDetailRow(
                      Icons.person_rounded,
                      'Nama Siswa',
                      response.studentName,
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      Icons.assignment_ind_rounded,
                      'NIS',
                      response.nis.isNotEmpty ? response.nis : '-',
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      Icons.schedule_rounded,
                      'Waktu Presensi',
                      response.time.isNotEmpty
                          ? '${response.date} ${response.time}'
                          : DateFormat(
                              'yyyy-MM-dd HH:i:ss',
                            ).format(DateTime.now()),
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      Icons.email_outlined,
                      'Notifikasi Orang Tua',
                      response.isSuccess
                          ? (response.message.contains(
                                  'Notifikasi telah dikirim',
                                )
                                ? 'Terkirim ke Email'
                                : 'Tidak Terkirim (Email Kosong)')
                          : '-',
                      isDark,
                      valueColor:
                          response.message.contains('Notifikasi telah dikirim')
                          ? Colors.teal
                          : Colors.grey,
                    ),
                  ] else ...[
                    _buildDetailRow(
                      Icons.qr_code_2_rounded,
                      'Kode QR Terdeteksi',
                      qrCode,
                      isDark,
                      valueStyle: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Pindai Berikutnya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Reusable bottom sheet row
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.indigo.shade300),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style:
                  valueStyle ??
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        valueColor ?? (isDark ? Colors.white : Colors.black87),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          return Stack(
            children: [
              MobileScanner(controller: _cameraController, onDetect: _onDetect),
              const ScannerOverlay(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12, width: 1),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      if (_viewModel.isProcessing)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Menghubungi Server...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _isFlashOn
                                  ? Colors.indigo.withOpacity(0.6)
                                  : Colors.black38,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white12,
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isFlashOn
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                await _cameraController.toggleTorch();
                                setState(() {
                                  _isFlashOn = !_isFlashOn;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: _isFrontCamera
                                  ? Colors.indigo.withOpacity(0.6)
                                  : Colors.black38,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white12,
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isFrontCamera
                                    ? Icons.camera_rear_rounded
                                    : Icons.camera_front_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                await _cameraController.switchCamera();
                                setState(() {
                                  _isFrontCamera = !_isFrontCamera;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.center_focus_weak_rounded,
                        color: Color(0xFF00FFCC),
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Posisikan Kode QR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Arahkan kamera ke kartu QR Code siswa di area pemindaian.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
