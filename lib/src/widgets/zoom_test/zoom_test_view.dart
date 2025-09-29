import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vmath;

void main() {
  runApp(const MaterialApp(home: ZoomBoundingDemo()));
}

class ZoomBoundingDemo extends StatefulWidget {
  const ZoomBoundingDemo({super.key});

  @override
  State<ZoomBoundingDemo> createState() => _ZoomBoundingDemoState();
}

class _ZoomBoundingDemoState extends State<ZoomBoundingDemo> {
  final TransformationController _tc = TransformationController();

  final List<Rect> boxes = [
    Rect.fromLTWH(100, 100, 150, 120),
    Rect.fromLTWH(400, 200, 100, 200),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zoom + Bounding Boxes")),
      body: Center(
        child: InteractiveViewer(
          transformationController: _tc,
          minScale: 0.5,
          maxScale: 5,
          child: Stack(
            children: [
              // Imagen simulada (rectángulo gris)
              CustomPaint(
                size: const Size(800, 600),
                painter: ImagePainter(),
              ),
              // Cajas en "mundo"
              CustomPaint(
                size: const Size(800, 600),
                painter: BoxPainter(_tc, boxes),
              ),
              // Overlay con handles fijos
              CustomPaint(
                size: const Size(800, 600),
                painter: OverlayPainter(_tc, boxes),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade300;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BoxPainter extends CustomPainter {
  final TransformationController tc;
  final List<Rect> boxes;
  BoxPainter(this.tc, this.boxes);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.transform(tc.value.storage);

    final scale = tc.value.getMaxScaleOnAxis();
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 / scale; // grosor constante en pantalla

    for (final r in boxes) {
      canvas.drawRect(r, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BoxPainter old) =>
      old.tc != tc || old.boxes != boxes;
}

class OverlayPainter extends CustomPainter {
  final TransformationController tc;
  final List<Rect> boxes;
  OverlayPainter(this.tc, this.boxes);

  @override
  void paint(Canvas canvas, Size size) {
    final m = tc.value;
    final double handleSize = 10.0;

    final paint = Paint()..color = Colors.red;

    for (final r in boxes) {
      final corners = [
        Offset(r.left, r.top),
        Offset(r.right, r.top),
        Offset(r.right, r.bottom),
        Offset(r.left, r.bottom),
      ];

      for (final c in corners) {
        final v = m.transform3(vmath.Vector3(c.dx, c.dy, 0));
        final screen = Offset(v.x, v.y);

        final rect = Rect.fromCenter(center: screen, width: handleSize, height: handleSize);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant OverlayPainter old) =>
      old.tc != tc || old.boxes != boxes;
}
