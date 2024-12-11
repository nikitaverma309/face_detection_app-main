import 'package:camera/camera.dart';
import 'package:face_detection_app/service/camera_service.dart';
import 'package:face_detection_app/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart' as imglib;
import 'image_converter.dart';
import 'locator.dart';

class FaceDetectorService {
  final CameraService _cameraService = serviceLocator<CameraService>();
  late FaceDetector _faceDetector;
  CameraImage? currentImage;
  bool captureImage = false;
  bool isProcessing = false; // Add this flag
  List<Face> _faces = [];

  List<Face> get faces => _faces;
  bool get faceDetected => _faces.isNotEmpty;

  void initialize() {
    Utils.printLog('Initializing Face Detector...');
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.1,
        enableClassification: true,
        enableContours: true,
        enableTracking: true,
      ),
    );
    Utils.printLog('Face Detector Initialized');
  }

  Future<void> detectFacesFromImage(CameraImage image) async {
    if (isProcessing) return; // Skip if already processing
    isProcessing = true; // Lock the processing

    try {
      InputImageData firebaseImageMetadata = InputImageData(
        imageRotation:
            _cameraService.cameraRotation ?? InputImageRotation.rotation0deg,
        inputImageFormat:
            InputImageFormatValue.fromRawValue(image.format.raw) ??
                InputImageFormat.yuv_420_888,
        size: Size(image.width.toDouble(), image.height.toDouble()),
        planeData: image.planes.map(
          (Plane plane) {
            return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            );
          },
        ).toList(),
      );

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      InputImage firebaseVisionImage = InputImage.fromBytes(
        bytes: bytes,
        inputImageData: firebaseImageMetadata,
      );

      _faces = await _faceDetector.processImage(firebaseVisionImage);

      if (_faces.isNotEmpty) {
        print('Faces detected: ${_faces.length}');
        Face detectedFace = _faces.first;

        // Validate and Crop Face
        if (validateFace(detectedFace)) {
          print("Valid face detected. Cropping...");
          final croppedImage = await cropFaceFromImage(image);
          if (croppedImage != null) {
            Utils.printLog("Face cropped and processed successfully.");
            // Process the cropped image (e.g., save or upload)
          }
        } else {
          print("Face not valid.");
        }
      } else {
        print("No faces detected.");
      }
    } catch (e) {
      print("Error detecting faces: $e");
    } finally {
      isProcessing = false; // Reset the flag
    }
  }

  bool validateFace(Face face) {
    // Custom validation logic (e.g., size, position)
    return face.boundingBox.width > 100 && face.boundingBox.height > 100;
  }

  Future<imglib.Image?> cropFaceFromImage(CameraImage cameraImage) async {
    try {
      final face = _faces.first;
      final boundingBox = face.boundingBox;

      final img.Image originalImage = convertCameraImage(cameraImage);

      const double expansionFactor = 0.2;
      final int extraWidth = (boundingBox.width * expansionFactor).toInt();
      final int extraHeight = (boundingBox.height * expansionFactor).toInt();

      final int x = (boundingBox.left.toInt() - extraWidth)
          .clamp(0, originalImage.width - 1);
      final int y = (boundingBox.top.toInt() - extraHeight)
          .clamp(0, originalImage.height - 1);
      final int width = (boundingBox.width.toInt() + 2 * extraWidth)
          .clamp(0, originalImage.width - x);
      final int height = (boundingBox.height.toInt() + 2 * extraHeight)
          .clamp(0, originalImage.height - y);

      if (width <= 0 || height <= 0) {
        Utils.printLog('Invalid crop dimensions: width=$width, height=$height');
        return null;
      }

      final img.Image faceImage =
          img.copyCrop(originalImage, x, y, width, height);

      print('Cropped Image Successfully.');
      return faceImage;
    } catch (e) {
      print('Error cropping face: $e');
      return null;
    }
  }

  dispose() {
    print('Disposing Face Detector...');
    _faceDetector.close();
    print('Face Detector disposed.');
  }
}
