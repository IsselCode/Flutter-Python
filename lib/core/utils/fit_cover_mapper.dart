// Mapeo para BoxFit.cover: de coordenadas de vista (widget) a frame real
import 'dart:math' as math;
import 'dart:ui';

class FitCoverMapper {
  final Size view;   // tamaño del widget que muestra el video
  final int fw, fh;  // resolución real del frame (usa /meta del backend)
  late final double _scale;
  late final double _dx;
  late final double _dy;

  late final double _offX;
  late final double _offY;

  FitCoverMapper(this.view, this.fw, this.fh) {
    final sx = view.width / fw;
    final sy = view.height / fh;
    _scale = math.max(sx, sy);
    _offY  = (view.height - fh * _scale) / 2.0;
    _offX = (view.width  - fw * _scale) / 2.0;
    _dx = (view.width  - fw * _scale) / 2.0;
    _dy = (view.height - fh * _scale) / 2.0;
  }

  Offset pViewToFrame(Offset p) {
    final fx = (p.dx - _dx) / _scale;
    final fy = (p.dy - _dy) / _scale;
    return Offset(
      fx.clamp(0, fw.toDouble()),
      fy.clamp(0, fh.toDouble()),
    );
  }

  // FRAME -> VIEW
  Offset pFrameToView(Offset p) => Offset(p.dx * _scale + _offX, p.dy * _scale + _offY);
  double lenFrameToView(double l) => l * _scale;

  double lenViewToFrame(double l) => l / _scale;
}