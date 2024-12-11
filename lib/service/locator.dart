import 'package:face_detection_app/service/face_detection_service.dart';
import 'package:get_it/get_it.dart';

import 'camera_service.dart';

final serviceLocator = GetIt.instance;

void setupServices() {
  serviceLocator.registerLazySingleton<CameraService>(() => CameraService());
  serviceLocator
      .registerLazySingleton<FaceDetectorService>(() => FaceDetectorService());
}
