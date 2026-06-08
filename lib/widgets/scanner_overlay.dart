import 'package:flutter/material.dart';

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

    // Calculate cutout bounds
    final double left = (width - scanAreaSize) / 2;
    final double top = (height - scanAreaSize) / 2;
    final Rect cutout = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // 1. Draw the semi-transparent black background outside the cutout
    final Path backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, width, height));
    final Path cutoutPath = Path()..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(20)));
    final Path finalPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    
    final Paint backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(finalPath, backgroundPaint);

    // 2. Draw modern high-tech glowing corner brackets
    final Paint borderPaint = Paint()
      ..color = scanLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 25.0;
    const double radius = 20.0;

    // Helper paths for the 4 corners
    // Top-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + radius)
        ..arcToPoint(Offset(left + radius, top), radius: const Radius.circular(radius))
        ..lineTo(left + cornerLength, top),
      borderPaint,
    );

    // Top-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top)
        ..lineTo(left + scanAreaSize - radius, top)
        ..arcToPoint(Offset(left + scanAreaSize, top + radius), radius: const Radius.circular(radius))
        ..lineTo(left + scanAreaSize, top + cornerLength),
      borderPaint,
    );

    // Bottom-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanAreaSize - cornerLength)
        ..lineTo(left, top + scanAreaSize - radius)
        ..arcToPoint(Offset(left + radius, top + scanAreaSize), radius: const Radius.circular(radius))
        ..lineTo(left + cornerLength, top + scanAreaSize),
      borderPaint,
    );

    // Bottom-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top + scanAreaSize)
        ..lineTo(left + scanAreaSize - radius, top + scanAreaSize)
        ..arcToPoint(Offset(left + scanAreaSize, top + scanAreaSize - radius), radius: const Radius.circular(radius))
        ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerLength),
      borderPaint,
    );

    // 3. Draw a modern laser scanner line moving up and down
    final double lineY = top + (scanAreaSize * animationValue);
    
    // Create a horizontal gradient for the laser line
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

    // Draw scanning laser line
    canvas.drawLine(Offset(left + 8, lineY), Offset(left + scanAreaSize - 8, lineY), laserPaint);

    // 4. Draw a subtle glowing backdrop below/above the laser for realism
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

    // Limit glow inside the cutout
    canvas.save();
    canvas.clipPath(cutoutPath);
    // Draw the glow above or below
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
