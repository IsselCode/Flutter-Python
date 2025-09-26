import 'dart:io';

import 'package:flutter_python_prueba/src/clean_features/dtos/start_camera_dto.dart';
import 'package:http/http.dart' as http;

import '../../core/http/endpoints.dart';

class CameraModel {

  Future<void> startCamera(StartCameraDto dto) async {

    try {

      final body = '''{
        "width":${dto.width},
        "height":${dto.height},
      }''';

      http.Response response = await http.post(
          Uri.parse(CameraAPI.startCamera),
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          body: body
      );

      if (response.statusCode != 200) {
        throw UnimplementedError();
      }

    } catch (e) {

      throw UnimplementedError();

    }

  }

  String streamCamera() => CameraAPI.stream;

}