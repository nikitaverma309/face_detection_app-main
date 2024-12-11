
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';


class FacePainter extends CustomPainter {
  FacePainter({
    required this.imageSize,
    required this.face,
  });

  bool accurateFace = false;
  final Size imageSize;
  double? scaleX, scaleY;
  Face? face;

  @override
  void paint(Canvas canvas, Size size) {
    if (face == null) return;

    Paint paint;

    // Detect face orientation (tilted or not)
    if (face!.headEulerAngleY! > 10 || face!.headEulerAngleY! < -10) {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Colors.red;
      if (accurateFace != false) {
        print("Face not accurate, turning red");
      }
      accurateFace = false;
    } else {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Colors.green;
      if (accurateFace != true) {
        accurateFace = true;
      }
    }

    // Scaling factors to adjust the face bounding box to the camera view
    scaleX = size.width / imageSize.width;
    scaleY = size.height / imageSize.height;

    // Drawing the bounding box around the detected face
    canvas.drawRRect(
      _scaleRect(
        rect: face!.boundingBox,
        imageSize: imageSize,
        widgetSize: size,
        scaleX: scaleX ?? 1,
        scaleY: scaleY ?? 1,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.face != face;
  }
}

RRect _scaleRect({
  required Rect rect,
  required Size imageSize,
  required Size widgetSize,
  double scaleX = 1,
  double scaleY = 1,
}) {
  // Adjust the bounding box according to the screen size and image size
  return RRect.fromLTRBR(
    (widgetSize.width - rect.left.toDouble() * scaleX),
    rect.top.toDouble() * scaleY,
    widgetSize.width - rect.right.toDouble() * scaleX,
    rect.bottom.toDouble() * scaleY,
    const Radius.circular(10),
  );
}
