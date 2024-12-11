import 'package:camera/camera.dart';
import 'package:face_detection_app/painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'face_detection_service.dart'; // Import the FaceDetectionService

class FaceDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const FaceDetectionScreen({required this.cameras, Key? key}) : super(key: key);

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _cameraController;
  late FaceDetectionService _faceDetectionService;
  bool _isProcessing = false;
  List<Face> _detectedFaces = [];

  @override
  void initState() {
    super.initState();
    _faceDetectionService = FaceDetectionService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = CameraController(
        widget.cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
        ResolutionPreset.high,
      );
      await _cameraController.initialize();
      _startFaceDetection();
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  void _startFaceDetection() {
    _cameraController.startImageStream((CameraImage cameraImage) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        final inputImage = _convertCameraImageToInputImage(cameraImage);
        final faces = await _faceDetectionService.detectFaces(inputImage);

        setState(() {
          _detectedFaces = faces;
        });
      } catch (e) {
        debugPrint("Error in face detection: $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  InputImage _convertCameraImageToInputImage(CameraImage cameraImage) {
    try {
      return InputImage.fromBytes(
        bytes: _concatenatePlanes(cameraImage.planes),
        metadata: InputImageMetadata(
          size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormatValue.fromRawValue(cameraImage.format.raw) ?? InputImageFormat.nv21,
          bytesPerRow: cameraImage.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint("Error converting camera image to input image: $e");
      rethrow;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  // Capture Image Method
  Future<void> _captureImage() async {
    if (_detectedFaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No face detected! Please align your face properly.")),
      );
      return;
    }

    final Face face = _detectedFaces.first;
    if (face.headEulerAngleY! > 10 || face.headEulerAngleY! < -10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Face not aligned! Please align your face properly.")),
      );
      return;
    }

    try {
      final image = await _cameraController.takePicture();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image captured: ${image.path}")),
      );
    } catch (e) {
      debugPrint("Error capturing image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Detection App')),
      body: Stack(
        children: [
          if (_cameraController.value.isInitialized)
            CameraPreview(_cameraController)
          else
            const Center(child: CircularProgressIndicator()),
          CustomPaint(
            painter: FacePainter(
              faces: _detectedFaces,
              imageSize: _cameraController.value.previewSize!,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
