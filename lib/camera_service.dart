// import 'package:camera/camera.dart';
//
// class CameraService {
//   CameraController? _cameraController;
//   List<CameraDescription> cameras = [];
//
//   Future<void> initializeCamera() async {
//     cameras = await availableCameras();
//     _cameraController = CameraController(
//       cameras[0],
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//     await _cameraController!.initialize();
//   }
//
//   Future<XFile?> captureImage() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return null;
//     }
//     return await _cameraController!.takePicture();
//   }
//
//   CameraController? get cameraController => _cameraController;
//
//   void dispose() {
//     _cameraController?.dispose();
//   }
// }
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];

  /// Initialize the front camera
  Future<void> initializeCameraWithFrontLens() async {
    cameras = await availableCameras();
    // Find the front camera
    CameraDescription? frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first, // Fallback if no front camera is found
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
  }

  /// Capture an image using the initialized camera
  Future<XFile?> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }
    return await _cameraController!.takePicture();
  }

  CameraController? get cameraController => _cameraController;

  void dispose() {
    _cameraController?.dispose();
  }
}

