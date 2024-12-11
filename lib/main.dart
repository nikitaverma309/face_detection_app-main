import 'package:camera/camera.dart';
import 'package:face_detection_app/view/check_emp_id_screen.dart';
import 'package:face_detection_app/view/enum_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FaceAttendanceScreen(
        action: CameraAction.login,
      )
    );
  }
}
