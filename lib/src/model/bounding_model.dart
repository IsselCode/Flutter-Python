
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_python_prueba/src/clean_features/dtos/create_bounding_box_dto.dart';
import 'package:http/http.dart' as http;

import '../../core/http/endpoints.dart';
import '../clean_features/dtos/update_bounding_box_dto.dart';
import '../clean_features/entities/oriented_box_entity.dart';
import '../widgets/overlay_bbox_widget.dart';

class BoundingModel {

  Future<void> setBBox(CreateBoundingBoxDto dto ) async {

    try {

      final body = dto.toJsonString();

      http.Response response = await http.post(
          Uri.parse(BboxAPI.base),
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

  Future<void> deleteBBoxById(int id) async {

    final uri = Uri.parse("${BboxAPI.base}/$id");

    try {
      var res = await http.delete(uri, headers: {HttpHeaders.acceptHeader: 'application/json'}).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 || res.statusCode == 204) {
        // Si tu server devuelve JSON con {"ok":true,...} y lo quieres leer:
        if (res.body.isNotEmpty &&
            res.headers['content-type']?.contains('json') == true) {
          final map = jsonDecode(res.body) as Map<String, dynamic>;
          if (map['ok'] != true) {
            throw HttpException('El servidor respondió ok=false: ${res.body}', uri: uri);
          }
          print(map);
        }
        return;
      }
      if (res.statusCode == 404) {
        throw StateError('Bounding box $id no existe (404)');
      }
      throw HttpException('DELETE falló ${res.statusCode}: ${res.body}', uri: uri);
    } on TimeoutException {
      throw TimeoutException('DELETE $uri tardó demasiado');
    } on SocketException catch (e) {
      throw HttpException('No se pudo conectar: ${e.message}', uri: uri);
    }
  }

  Future<void> updateBBoxById(UpdateBoundingBoxDto dto) async {

    final uri = Uri.parse("${BboxAPI.base}/${dto.id}");

    try {

      final body = dto.toJsonString();

      http.Response res = await http.patch(
        uri,
        body: body,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'}).timeout(const Duration(seconds: 5),
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        // Si tu server devuelve JSON con {"ok":true,...} y lo quieres leer:
        if (res.body.isNotEmpty &&
            res.headers['content-type']?.contains('json') == true) {
          final map = jsonDecode(res.body) as Map<String, dynamic>;
          if (map['ok'] != true) {
            throw HttpException('El servidor respondió ok=false: ${res.body}', uri: uri);
          }
          print(map);
        }
        return;
      }
      if (res.statusCode == 404) {
        throw StateError('Bounding box ${dto.id} no existe (404)');
      }
      throw HttpException('PATCH falló ${res.statusCode}: ${res.body}', uri: uri);
    } on TimeoutException {
      throw TimeoutException('PATCH $uri tardó demasiado');
    } on SocketException catch (e) {
      throw HttpException('No se pudo conectar: ${e.message}', uri: uri);
    }
  }

  Future<void> clearBBox() async {

  }

  /// Lee boxes del backend y los convierte a OrientedBBox en VISTA.
  /// `pFrameToView` y `lenFrameToView` vienen de tu _FitCoverMapper.
  Future<List<OrientedBBox>> getBboxes({
    String source = 'db', // 'db' | 'worker' | 'both'
    required PointMap pFrameToView,
    required LenMap lenFrameToView,
  }) async {

    final uri = Uri.parse(BboxAPI.bboxes).replace(queryParameters: {'source': source});

    http.Response res;
    try {
      res = await http
          .get(uri, headers: {HttpHeaders.contentTypeHeader: 'application/json'})
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw TimeoutException('GET $uri tardó demasiado');
    } on SocketException catch (e) {
      throw HttpException('No se pudo conectar: ${e.message}', uri: uri);
    }

    if (res.statusCode != 200) {
      throw HttpException('GET falló ${res.statusCode}: ${res.body}', uri: uri);
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (map['ok'] != true) {
      throw HttpException('ok=false: ${res.body}', uri: uri);
    }

    // Selección de lista según `source`
    List<dynamic> raw;
    if (source == 'both') {
      // por defecto devolvemos los de DB; si quieres, aquí puedes fusionar con worker_items
      raw = (map['db_items'] as List?) ?? const [];
    } else {
      raw = (map['items'] as List?) ?? const [];
    }

    return raw
        .cast<Map<String, dynamic>>()
        .map((j) => OrientedBBox.fromServerJson(
      j,
      pFrameToView: pFrameToView,
      lenFrameToView: lenFrameToView,
    ))
        .toList(growable: false);
  }

}