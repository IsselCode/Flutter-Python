
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_python_prueba/src/widgets/bbox_editor/bbox_fit_cover_mapper.dart';
import 'package:flutter_python_prueba/src/clean_features/dtos/create_bounding_box_dto.dart';
import 'package:http/http.dart' as http;

import '../../core/http/endpoints.dart';
import '../clean_features/dtos/update_bounding_box_dto.dart';
import '../widgets/bbox_editor/bbox_entity.dart';
import '../widgets/bbox_editor/bbox_overlay.dart';

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

  /// Lee boxes del backend y los convierte a BBoxEntity en VISTA.
  Future<List<BBoxEntity>> getBboxes({
    required FitCoverMapper mapper,
  }) async {

    final uri = Uri.parse(BboxAPI.bboxes);

    http.Response res;
    try {
      res = await http.get(uri, headers: {HttpHeaders.contentTypeHeader: 'application/json'}).timeout(const Duration(seconds: 5));
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

    // Selección de lista
    List<dynamic> raw = (map['items'] as List?) ?? const [];

    return raw.map((e) => BBoxEntity.fromServerJson(e, mapper: mapper),).toList();
  }

}