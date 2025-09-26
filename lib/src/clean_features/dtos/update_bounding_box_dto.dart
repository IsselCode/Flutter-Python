import 'dart:convert';

class UpdateBoundingBoxDto {

  final int id;
  final double cx;
  final double cy;
  final double w;
  final double h;
  final double angleDeg;
  final String colorHex;

  UpdateBoundingBoxDto({
    required this.id,
    required this.cx,
    required this.cy,
    required this.w,
    required this.h,
    required this.angleDeg,
    required this.colorHex,
  });

  Map<String, dynamic> toJson() => {
    "cx": cx,
    "cy": cy,
    "w":  w,
    "h":  h,
    "angle_deg": angleDeg,
    "color_hex": colorHex, // ej. "#FFB400"
  };

  String toJsonString() => jsonEncode(toJson());

}