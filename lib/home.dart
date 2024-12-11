import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'face_detection_screen.dart';  // Import the face detection screen

class HomePage extends StatelessWidget {
   HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Fetch the available cameras
            final cameras = await availableCameras();

            // Navigate to the FaceDetectionScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FaceDetectionScreen(cameras: cameras),
              ),
            );
          },
          child: const Text('Go to Face Detection'),
        ),
      ),
    );
  }
}
