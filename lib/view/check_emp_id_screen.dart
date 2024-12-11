import 'package:face_detection_app/view/camera_pic.dart';
import 'package:flutter/material.dart';

import 'enum_screen.dart';


class FaceAttendanceScreen extends StatefulWidget {
  final CameraAction action;
  const FaceAttendanceScreen({super.key, required this.action});

  @override
  State<FaceAttendanceScreen> createState() => _FaceAttendanceScreenState();
}

class _FaceAttendanceScreenState extends State<FaceAttendanceScreen> {


  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // MediaQuery for responsive height and width
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xF5ECF4F5),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginCameraTwo(
                        attendanceId: "12345", // Pass your attendanceId here
                        action: CameraAction.login, // Pass your CameraAction here
                      ),
                    ),
                  );
                },
                child: const Text("Navigate to LoginCameraTwo"),
              )


            ],
          ),
        ),
      ),

    );
  }
}
