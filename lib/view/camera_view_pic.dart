import 'dart:io';
import 'package:flutter/material.dart';
import 'enum_screen.dart';

class LoginCameraViewTwo extends StatefulWidget {
  final CameraAction action;
  final String? attendanceId;
  final File? imageFile;
  const LoginCameraViewTwo(
      {super.key,
      this.imageFile,
      required this.action,
      required this.attendanceId});

  @override
  State<LoginCameraViewTwo> createState() => _LoginCameraViewTwoState();
}

class _LoginCameraViewTwoState extends State<LoginCameraViewTwo> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff176daa),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                0.05 * screenWidth,
                0.025 * screenHeight,
                0.05 * screenWidth,
                0.04 * screenHeight,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF484646),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0.03 * screenHeight),
                  topRight: Radius.circular(0.03 * screenHeight),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.012),
                  Material(
                    elevation: 44,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff204867),
                        borderRadius: BorderRadius.circular(1),
                        border: Border.all(
                          color: Colors.blueGrey,
                          width: 6.0,
                        ),
                      ),
                      child: widget.imageFile != null
                          ? Image.file(
                              widget.imageFile!,
                              fit: BoxFit.contain,
                              height: screenHeight * 0.4,
                            )
                          : Icon(
                              Icons.camera_alt,
                              size: screenHeight * 0.09,
                              color: const Color(0xffa2cccc),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
