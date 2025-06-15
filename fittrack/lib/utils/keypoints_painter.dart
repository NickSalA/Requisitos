import 'package:flutter/material.dart';

class KeypointsPainter extends CustomPainter {
  final List<List<double>> keypoints;
  final Size? previewSize; // Tamaño real de la preview de la cámara

  KeypointsPainter(this.keypoints, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (previewSize == null) return;

    // Ajusta el escalado para que coincida con la preview real
    final scaleX = size.width / previewSize!.height;
    final scaleY = size.height / previewSize!.width;

    final Paint dotPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 6.0
      ..style = PaintingStyle.fill;

    for (final k in keypoints) {
      // Normalmente k = [x, y, conf]
      final dx = k[0] * scaleX;
      final dy = k[1] * scaleY;
      canvas.drawCircle(Offset(dx, dy), 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
