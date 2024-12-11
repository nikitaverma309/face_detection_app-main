import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;

  FacePainter({required this.faces, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paintGreen = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint paintRed = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (Face face in faces) {
      final rect = Rect.fromLTRB(
        size.width - (face.boundingBox.right / imageSize.width * size.width),
        face.boundingBox.top / imageSize.height * size.height,
        size.width - (face.boundingBox.left / imageSize.width * size.width),
        face.boundingBox.bottom / imageSize.height * size.height,
      );

      final Paint paint = (face.headEulerAngleY! > 10 || face.headEulerAngleY! < -10)
          ? paintRed
          : paintGreen;

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}