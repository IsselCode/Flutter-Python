import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/src/model/camera_model.dart';
import 'package:flutter_python_prueba/src/clean_features/dtos/start_camera_dto.dart';

class CameraController extends ChangeNotifier {

  CameraModel cameraModel;

  CameraController({
    required this.cameraModel
  });

  Future<void> startCamera() async {

    StartCameraDto dto = StartCameraDto(width: 1920, height: 1080);

    await cameraModel.startCamera(dto);
  }

  String streamCamera() => cameraModel.streamCamera();

}