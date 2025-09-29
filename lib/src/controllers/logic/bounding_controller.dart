import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/core/utils/fit_cover_mapper.dart';
import 'package:flutter_python_prueba/src/clean_features/dtos/create_bounding_box_dto.dart';
import 'package:flutter_python_prueba/src/clean_features/dtos/update_bounding_box_dto.dart';

import '../../../core/utils/random_hex_color.dart';
import '../../clean_features/entities/oriented_box_entity.dart';
import '../../model/bounding_model.dart';

class BoundingController extends ChangeNotifier {

  BoundingModel boundingModel;

  BoundingController({
    required this.boundingModel,
  });

  List<OrientedBBox> initialBBoxes = [];

  Future<List<OrientedBBox>> getBBoxes(FitCoverMapper mapper) async => await boundingModel.getBboxes(mapper: mapper);

  Future<void> sendBBoxOBB(OrientedBBox obb, Size viewSize, int frameWidth, int frameHeight) async {

    CreateBoundingBoxDto dto = CreateBoundingBoxDto(
      id: obb.id,
      cx: obb.centerF.dx,
      cy: obb.centerF.dy,
      w: obb.wF,
      h: obb.hF,
      angleDeg: obb.angleDegScreen,
      colorHex: ColorUtils.colorToHex(obb.color)
    );

    await boundingModel.setBBox(dto);
  }

  Future<void> deleteBBoxById(int id) async {
    await boundingModel.deleteBBoxById(id);
  }

  Future<void> updateBBoxById(OrientedBBox obb, Size viewSize, int frameWidth, int frameHeight) async {

    UpdateBoundingBoxDto dto = UpdateBoundingBoxDto(
      id: obb.id,
      cx: obb.centerF.dx,
      cy: obb.centerF.dy,
      w: obb.wF,
      h: obb.hF,
      angleDeg: obb.angleDegScreen,
      colorHex: ColorUtils.colorToHex(obb.color)
    );

    await boundingModel.updateBBoxById(dto);
  }

}