import 'package:flutter/material.dart';

// FUNGSI: Ini hanya Widget Kosmetik.
// Membuat efek gelap di luar kotak dan garis kotak pemindai ala "High-Tech" di halaman Kamera.
class ScannerOverlay extends StatefulWidget {
  final double scanAreaSize;
  final Color overlayColor;
  final Color scanLineColor;

  const ScannerOverlay({
    super.key,
    this.scanAreaSize = 260.0,
    this.overlayColor = const Color(0x99000000),
    this.scanLineColor = const Color(0xFF00FFCC),
  });

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ScannerOverlayPainter(
            scanAreaSize: widget.scanAreaSize,
            overlayColor: widget.overlayColor,
            scanLineColor: widget.scanLineColor,
            animationValue: _animationController.value,
          ),
        );
      },
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final Color overlayColor;
  final Color scanLineColor;
  final double animationValue;

  ScannerOverlayPainter({
    required this.scanAreaSize,
    required this.overlayColor,
    required this.scanLineColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Menentukan posisi kotak tengah (area transparan untuk nge-scan)
    final double left = (width - scanAreaSize) / 2;
    final double top = (height - scanAreaSize) / 2;
    final Rect cutout = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // 1. Menggambar latar belakang yang agak gelap (kamera sekitarnya)
    // Supaya kotak tengahnya terlihat terang dan menonjol
    final Path backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, width, height));
    final Path cutoutPath = Path()..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(20)));
    // Membuat lubang tembus pandang di tengah
    final Path finalPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    
    final Paint backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(finalPath, backgroundPaint);

    // 2. Menggambar garis-garis siku di 4 pojokan kotak scan (Mirip desain High-Tech/Sci-fi)
    final Paint borderPaint = Paint()
      ..color = scanLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 25.0; // Panjang sisi siku
    const double radius = 20.0;       // Lengkungan sudut siku

    // Pojok Kiri Atas
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + radius)
        ..arcToPoint(Offset(left + radius, top), radius: const Radius.circular(radius))
        ..lineTo(left + cornerLength, top),
      borderPaint,
    );

    // Pojok Kanan Atas
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top)
        ..lineTo(left + scanAreaSize - radius, top)
        ..arcToPoint(Offset(left + scanAreaSize, top + radius), radius: const Radius.circular(radius))
        ..lineTo(left + scanAreaSize, top + cornerLength),
      borderPaint,
    );

    // Pojok Kiri Bawah
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanAreaSize - cornerLength)
        ..lineTo(left, top + scanAreaSize - radius)
        ..arcToPoint(Offset(left + radius, top + scanAreaSize), radius: const Radius.circular(radius))
        ..lineTo(left + cornerLength, top + scanAreaSize),
      borderPaint,
    );

    // Pojok Kanan Bawah
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top + scanAreaSize)
        ..lineTo(left + scanAreaSize - radius, top + scanAreaSize)
        ..arcToPoint(Offset(left + scanAreaSize, top + scanAreaSize - radius), radius: const Radius.circular(radius))
        ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerLength),
      borderPaint,
    );

    // 3. Menggambar garis Laser pemindai yang naik-turun
    // Posisi garis Y berubah-ubah karena ada nilai animasi dari waktu ke waktu
    final double lineY = top + (scanAreaSize * animationValue);
    
    // Memberikan gradasi warna biar terlihat nyata (redup di pinggir, terang di tengah)
    final Shader laserShader = LinearGradient(
      colors: [
        scanLineColor.withOpacity(0.0),
        scanLineColor.withOpacity(0.8),
        scanLineColor,
        scanLineColor.withOpacity(0.8),
        scanLineColor.withOpacity(0.0),
      ],
      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
    ).createShader(Rect.fromLTRB(left, lineY - 2, left + scanAreaSize, lineY + 2));

    final Paint laserPaint = Paint()
      ..shader = laserShader
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Mulai menggambar garis Lasernya di atas kanvas
    canvas.drawLine(Offset(left + 8, lineY), Offset(left + scanAreaSize - 8, lineY), laserPaint);

    // 4. Efek bayangan menyala (glowing) tipis mengikuti laser
    final Paint glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          scanLineColor.withOpacity(0.15),
          scanLineColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(left, lineY - 20, scanAreaSize, 40))
      ..style = PaintingStyle.fill;

    // Memastikan bayangannya tidak bocor keluar batas kotak scan
    canvas.save();
    canvas.clipPath(cutoutPath);
    // Menggambar bayangan menyala
    canvas.drawRect(Rect.fromLTWH(left, lineY - 15, scanAreaSize, 15), glowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scanAreaSize != scanAreaSize ||
        oldDelegate.scanLineColor != scanLineColor ||
        oldDelegate.overlayColor != overlayColor;
  }
}
