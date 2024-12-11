
import 'dart:io';
import 'dart:math' as math;
import 'package:face_detection_app/view/enum_screen.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../service/camera_service.dart';
import '../service/face_detection_service.dart';
import '../service/image_converter.dart';
import '../service/locator.dart';
import '../service/painter.dart';
import '../utils.dart';
import 'camera_view_pic.dart';


class LoginCameraTwo extends StatefulWidget {
  final String? attendanceId;
  final CameraAction action;
  const LoginCameraTwo({super.key, required this.attendanceId, required this.action});

  @override
  LoginCameraTwoState createState() => LoginCameraTwoState();
}

class LoginCameraTwoState extends State<LoginCameraTwo> {
  String? imagePath;
  Face? faceDetected;
  Size? imageSize;
  bool pictureTaken = false;
  bool _initializing = false;
  RxBool isFaceDetected = false.obs;

  // Service injection
  final FaceDetectorService _faceDetectorService = serviceLocator<FaceDetectorService>();
  final CameraService _cameraService = serviceLocator<CameraService>();

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  _start() async {
    setState(() => _initializing = true);
    print("Initializing camera and face detector...");
    await _cameraService.initialize();
    print("Camera initialized.");
    _faceDetectorService.initialize();
    print("Face detector initialized.");
    setState(() => _initializing = false);
    _frameFaces();
  }

  // This method is called when a face is detected and automatically captures the image.
  _captureImageAutomatically(cameraImage) async {
    try {
      _faceDetectorService.currentImage = cameraImage;
      _faceDetectorService.captureImage = false;
      Utils.printLog('Capturing new image...');
      final imglib.Image? imgCrop = await _faceDetectorService.cropFaceFromImage(cameraImage);

      if (imgCrop == null) {
        throw Exception("Failed to crop the face from the image.");
      }
      print("Face cropped successfully: $imgCrop");

      final File imgFile = await convertImageToFile(imgCrop);
      if (imgFile == null) {
        throw Exception("Failed to convert cropped image to file.");
      }
      print("Image file created: $imgFile");

      if (mounted) {
        // Automatically navigate after face detection and image capture
        Get.off(() => LoginCameraViewTwo(
          imageFile: imgFile,
          attendanceId: widget.attendanceId,
          action: widget.action,
        ));
      }
    } catch (e) {
      print("Error capturing image: $e");
      // Optionally show a dialog to inform the user of the error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Error capturing image: $e"),
          );
        },
      );
    }
  }

  _frameFaces() {
    imageSize = _cameraService.getImageSize();
    _cameraService.cameraController?.startImageStream((cameraImage) async {
      try {
        print("Processing camera image...");
        await _faceDetectorService.detectFacesFromImage(cameraImage);

        if (_faceDetectorService.faces.length == 1) {
          print("Face detected.");
          if (mounted) {
            setState(() {
              faceDetected = _faceDetectorService.faces[0];
            });
            isFaceDetected(Utils.isValidFace(faceDetected));
            // Automatically capture image when face is detected
            if (isFaceDetected.value) {
              print("Face is valid. Capturing image...");
              _captureImageAutomatically(cameraImage);
            }
          }
        } else {
          print("No valid face detected.");
          if (mounted) {
            isFaceDetected(false);
            setState(() {
              faceDetected = null;
            });
          }
        }
      } catch (e) {
        print('Error in face detection: $e');
        // Optionally show a dialog to inform the user of the error
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("Error in face detection: $e"),
            );
          },
        );
      }
    });
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  static double mirror = math.pi;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    late Widget body;
    if (_initializing) {
      body = const Center(child: CircularProgressIndicator());
    } else if (pictureTaken && imagePath != null) {
      body = SizedBox(
        width: width,
        height: height,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(mirror),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.file(File(imagePath!)),
          ),
        ),
      );
    } else {
      body = Transform.scale(
        scale: 1.0,
        child: AspectRatio(
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: SizedBox(
                width: width,
                height: _cameraService.cameraController != null
                    ? width * _cameraService.cameraController!.value.aspectRatio
                    : 0,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (_cameraService.cameraController != null)
                      CameraPreview(_cameraService.cameraController!),
                    if (faceDetected != null)
                      CustomPaint(
                        painter: FacePainter(
                          face: faceDetected!,
                          imageSize: imageSize!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          body,
          CameraHeader(
            widget.action == CameraAction.login
                ? "Login with face"
                : "Strings.signUp",
            onBackPressed: _onBackPressed,
          ),
        ],
      ),
    );
  }
}


class CameraHeader extends StatelessWidget {
  const CameraHeader(this.title, {super.key, this.onBackPressed});
  final String title;
  final void Function()? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.black, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onBackPressed,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 50,
              width: 50,
              child: const Center(child: Icon(Icons.arrow_back)),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            width: 90,
          )
        ],
      ),
    );
  }
}
