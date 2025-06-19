import 'package:flutter/material.dart';

class KeypointsPainter extends CustomPainter {
  final List<List<double>> keypoints; // [17][3] [x, y, score]
  final Size cameraPreviewSize;

  KeypointsPainter(this.keypoints, this.cameraPreviewSize);

  // Define los pares de puntos a conectar (esqueleto)
  static final List<List<int>> skeleton = [
    [5, 7], [7, 9], // Left arm
    [6, 8], [8, 10], // Right arm
    [11, 13], [13, 15], // Left leg
    [12, 14], [14, 16], // Right leg
    [5, 6], [11, 12], [5, 11], [6, 12], // Torso
    [0, 1], [0, 2], [1, 3], [2, 4], [0, 6] // Head
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Calcular escala entre preview de cámara y canvas
    final double scaleX = size.width / cameraPreviewSize.width;
    final double scaleY = size.height / cameraPreviewSize.height;

    final pointPaint = Paint()
      ..color = Colors.deepPurpleAccent
      ..style = PaintingStyle.fill
      ..strokeWidth = 8;

    // Dibuja los puntos (keypoints)
    for (final kp in keypoints) {
      if (kp.length < 3 || kp[2] < 0.1) continue;
      final x = kp[0] * scaleX;
      final y = kp[1] * scaleY;
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
    }

    // Dibuja las líneas del esqueleto
    final linePaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.7)
      ..strokeWidth = 3;

    for (final pair in skeleton) {
      final kp1 = keypoints[pair[0]];
      final kp2 = keypoints[pair[1]];
      if (kp1.length < 3 || kp2.length < 3) continue;
      if (kp1[2] > 0.3 && kp2[2] > 0.3) {
        final p1 = Offset(kp1[0] * scaleX, kp1[1] * scaleY);
        final p2 = Offset(kp2[0] * scaleX, kp2[1] * scaleY);
        canvas.drawLine(p1, p2, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(KeypointsPainter oldDelegate) =>
      oldDelegate.keypoints != keypoints;
}
