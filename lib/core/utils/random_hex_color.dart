import 'dart:math';
import 'package:flutter/material.dart';

class ColorUtils {
  /// Genera un Color aleatorio
  static Color randomColor() {
    final random = Random();
    return Color.fromARGB(
      255, // opacidad fija (FF)
      random.nextInt(256), // rojo
      random.nextInt(256), // verde
      random.nextInt(256), // azul
    );
  }

  /// Convierte un Color a un string hexadecimal tipo "#RRGGBB"
  static String colorToHex(Color color, {bool leadingHashSign = true}) {
    return '${leadingHashSign ? '#' : ''}'
        '${color.red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${color.green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${color.blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  /// Convierte un string hexadecimal tipo "#RRGGBB" o "RRGGBB" a Color
  static Color hexToColor(String hexString) {
    String hex = hexString.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // agrega alpha (FF = opacidad completa)
    }
    return Color(int.parse(hex, radix: 16));
  }
}
