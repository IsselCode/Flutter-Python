import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/src/controllers/logic/bounding_controller.dart';
import 'package:provider/provider.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

import '../controllers/logic/camera_controller.dart';
import '../widgets/overlay_bbox_widget.dart';

class CamBBoxRotateView extends StatefulWidget {
  final String base;   // p.ej. http://10.0.2.2:5000
  final int frameW;    // resolución real del frame en backend
  final int frameH;
  const CamBBoxRotateView({
    super.key,
    required this.base,
    this.frameW = 640,
    this.frameH = 480,
  });

  @override
  State<CamBBoxRotateView> createState() => _CamBBoxRotateViewState();
}

class _CamBBoxRotateViewState extends State<CamBBoxRotateView> {
  Size _viewSize = Size.zero;

  late Future<void> _startCameraFuture;

  @override
  void initState() {
    super.initState();
    CameraController camCtrl = context.read();
    BoundingController bCtrl = context.read();
    _startCameraFuture = camCtrl.startCamera();
  }

  @override
  Widget build(BuildContext context) {
    CameraController camCtrl = context.read();

    return Scaffold(
      body: FutureBuilder(
        future: _startCameraFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //* Body
              Expanded(
                child: Column(
                  children: [
                    //* Barra de herramientas
                    Expanded(
                      child: Container(

                      ),
                    ),
                    //* Imagen
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: LayoutBuilder(
                        builder: (context, c) {
                          _viewSize = Size(c.maxWidth, c.maxHeight);

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              //* VIDEO
                              MJPEGStreamScreen(
                                streamUrl: camCtrl.streamCamera(),
                                borderRadius: 0,
                                watermarkText: "Issel Code",
                                width: _viewSize.width,
                                height: _viewSize.height,
                                showLiveIcon: false,
                                showLogs: false,
                                blurSensitiveContent: false,
                                showWatermark: true,
                              ),
                              //* PAINTER BOUNDINGS
                              GetVideoWidget(
                                viewSize: _viewSize,
                                frameW: widget.frameW,
                                frameH: widget.frameH,
                              ),


                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              //* Right Panel
              Container(
                width: 300,
                color: Colors.red,
              )
            ],
          );

        },
      )
    );
  }
}


class GetVideoWidget extends StatefulWidget {
  final Size viewSize;
  final int frameW;    // resolución real del frame en backend
  final int frameH;

  const GetVideoWidget({
    super.key,
    required this.viewSize,
    required this.frameH,
    required this.frameW
  });

  @override
  State<GetVideoWidget> createState() => _GetVideoWidgetState();
}

class _GetVideoWidgetState extends State<GetVideoWidget> {
  final overlayCtrl = MultiBBoxOverlayController();
  late Future<void> _getBBoxesFuture;

  @override
  void initState() {
    super.initState();
    BoundingController bCtrl = context.read();
    _getBBoxesFuture = bCtrl.getBBoxes(widget.viewSize, widget.frameW, widget.frameH);
  }

  @override
  Widget build(BuildContext context) {
    CameraController camCtrl = context.read();
    BoundingController bCtrl = context.watch();

    return FutureBuilder(
        future: _getBBoxesFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // 2) Overlay de edición
          return MultiBBoxOverlay(
            viewSize: widget.viewSize,
            controller: overlayCtrl,
            onCommitBox: (box, kind) async {
              switch (kind) {
                case CommitKind.create:
                  await bCtrl.sendBBoxOBB(box, widget.viewSize, widget.frameW, widget.frameH);
                  break;
                case CommitKind.update:
                  print(box.id);
                  await bCtrl.updateBBoxById(box, widget.viewSize, widget.frameW, widget.frameH);
                  break;
                case CommitKind.delete:
                  await bCtrl.deleteBBoxById(box.id);
                  break;
              }
            },
            initialBoxes: bCtrl.initialBBoxes,
          );
        },
      );
  }
}
