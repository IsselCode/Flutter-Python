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

  Future<void> getBBoxes(Size viewSize, int frameWidth, int frameHeight) async {
    final mapper = FitCoverMapper(viewSize, frameWidth, frameHeight);
    initialBBoxes = await boundingModel.getBboxes(pFrameToView: mapper.pFrameToView, lenFrameToView: mapper.lenFrameToView);
    notifyListeners();
  }

  Future<void> sendBBoxOBB(OrientedBBox obb, Size viewSize, int frameWidth, int frameHeight) async {
    final mapper = FitCoverMapper(viewSize, frameWidth, frameHeight);

    // centro y tamaños en coordenadas de FRAME
    final centerF = mapper.pViewToFrame(obb.center);
    final wF = mapper.lenViewToFrame(obb.w);
    final hF = mapper.lenViewToFrame(obb.h);

    // tu OrientedBBox usa ángulo en RAD → pásalo a GRADOS para el backend
    final angleDegScreen = obb.angle * 180.0 / math.pi;

    CreateBoundingBoxDto dto = CreateBoundingBoxDto(
      id: obb.id,
      cx: centerF.dx,
      cy: centerF.dy,
      w: wF,
      h: hF,
      angleDeg: angleDegScreen,
      colorHex: ColorUtils.colorToHex(obb.color)
    );

    await boundingModel.setBBox(dto);
  }

  Future<void> deleteBBoxById(int id) async {
    await boundingModel.deleteBBoxById(id);
  }

  Future<void> updateBBoxById(OrientedBBox obb, Size viewSize, int frameWidth, int frameHeight) async {
    final mapper = FitCoverMapper(viewSize, frameWidth, frameHeight);

    // centro y tamaños en coordenadas de FRAME
    final centerF = mapper.pViewToFrame(obb.center);
    final wF = mapper.lenViewToFrame(obb.w);
    final hF = mapper.lenViewToFrame(obb.h);

    // tu OrientedBBox usa ángulo en RAD → pásalo a GRADOS para el backend
    final angleDegScreen = obb.angle * 180.0 / math.pi;

    UpdateBoundingBoxDto dto = UpdateBoundingBoxDto(
      id: obb.id,
      cx: centerF.dx,
      cy: centerF.dy,
      w: wF,
      h: hF,
      angleDeg: angleDegScreen,
      colorHex: ColorUtils.colorToHex(obb.color)
    );

    await boundingModel.updateBBoxById(dto);
  }

}