
import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/src/controllers/logic/bounding_controller.dart';
import 'package:provider/provider.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

import '../controllers/logic/camera_controller.dart';
import '../widgets/overlay_bbox_widget.dart';

class BBoxEditor extends StatefulWidget {

  final String stream;   // p.ej. http://10.0.2.2:5000
  final int frameW;    // resolución real del frame en backend
  final int frameH;


  const BBoxEditor({
    super.key,
    required this.stream,
    this.frameW = 640,
    this.frameH = 480,
  });

  @override
  State<BBoxEditor> createState() => _BBoxEditorState();
}

class _BBoxEditorState extends State<BBoxEditor> {
  Size _viewSize = Size.zero;
  bool cameraStreamError = false;

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
        body: SafeArea(

          child: FutureBuilder(
            future: _startCameraFuture,
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(),);
              }

              return AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(
                  builder: (context, c) {
                    _viewSize = Size(c.maxWidth, c.maxHeight);

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        //* VIDEO
                        MJPEGStreamScreen(
                          streamUrl: widget.stream,
                          borderRadius: 0,
                          watermarkText: "Issel Code",
                          width: _viewSize.width,
                          height: _viewSize.height,
                          showLiveIcon: false,
                          showLogs: false,
                          blurSensitiveContent: false,
                          showWatermark: true,
                          onRetry: () {
                            CameraController camCtrl = context.read();
                            _startCameraFuture = camCtrl.startCamera();
                          },
                          onError: () {
                            cameraStreamError = true;
                            setState(() {});
                          },
                          onStartCamera: () {
                            cameraStreamError = false;
                            setState(() {});
                          },
                        ),

                        //* PAINTER BOUNDINGS
                        if (!cameraStreamError)
                          GetVideoWidget(
                            viewSize: _viewSize,
                            frameW: widget.frameW,
                            frameH: widget.frameH,
                          ),


                      ],
                    );
                  },
                ),
              );

            },
          ),
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
