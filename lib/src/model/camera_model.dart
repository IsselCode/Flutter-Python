import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;

import '../../core/http/endpoints.dart';

class CameraModel {

  Future<Size> startCamera() async {
    final uri = Uri.parse(CameraAPI.startCamera);
    http.Response res;

    try {
      res = await http.post(uri, headers: {HttpHeaders.contentTypeHeader: "application/json"},).timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw TimeoutException('GET $uri tardó demasiado');
    } on SocketException catch (e) {
      throw HttpException('No se pudo conectar: ${e.message}', uri: uri);
    }

    if (res.statusCode != 200) {
      throw HttpException(
          'POST falló ${res.statusCode}: ${res.body}', uri: uri);
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (map['ok'] != true) {
      throw HttpException('ok=false: ${res.body}', uri: uri);
    }

    return Size(map["w"].toDouble(), map["h"].toDouble());
  }

  String streamCamera() => CameraAPI.stream;

}