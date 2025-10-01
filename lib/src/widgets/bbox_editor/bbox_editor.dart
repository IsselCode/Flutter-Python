import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/src/controllers/logic/bounding_controller.dart';
import 'package:flutter_python_prueba/src/widgets/bbox_editor/bbox_editor_controller.dart';
import 'package:provider/provider.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

import 'bbox_fit_cover_mapper.dart';
import 'bbox_entity.dart';
import '../../controllers/logic/camera_controller.dart';
import 'bbox_helpers.dart';
import 'bbox_overlay.dart';
import 'bbox_editor_enums.dart';

class BBoxEditor extends StatefulWidget {
  final String stream;
  final Size camResolution;
  final BBoxEditorController? controller;
  final Future<List<BBoxEntity>> Function(FitCoverMapper mapper)? onStreamReadyFutureBoundings;
  final Future<void> Function(BBoxEntity box, CommitKind kind, CommitOrigin commitOrigin)? onCommitBox;

  final VoidCallback? onStreamError;
  final VoidCallback? onStreamReady;
  final VoidCallback? onRetry;

  final ToolPolicy policy;
  final bool logs;

  const BBoxEditor({
    super.key,
    required this.stream,
    required this.camResolution,
    this.policy = ToolPolicy.platformDefault,
    this.controller,
    this.onRetry,
    this.onStreamError,
    this.onStreamReady,
    this.onStreamReadyFutureBoundings,
    this.onCommitBox,
    this.logs = true
  });

  @override
  State<BBoxEditor> createState() => _BBoxEditorState();
}

class _BBoxEditorState extends State<BBoxEditor> {
  final _tc = TransformationController();
  bool cameraStreamError = false;
  bool _loadingInitial = false;
  BBoxEditorController get _ctrl => widget.controller ?? (throw ArgumentError('controller es requerido'));

  @override
  void initState() {
    super.initState();
    _ctrl.cameraResolution = widget.camResolution;
  }

  BBoxTool get effectiveTool {
    final p = widget.policy;
    switch (p) {
      case ToolPolicy.enforced:
        return widget.controller!.bBoxTool.value;
      case ToolPolicy.platformDefault:
        return isMobileLike ? widget.controller!.bBoxTool.value : BBoxTool.bboxs;
    }
  }

  // Flags ya resueltos para que el widget no repita lógica
  bool get allowZoom {
    final p = widget.policy;
    if (isDesktopLike && p != ToolPolicy.enforced) return true;
    return effectiveTool == BBoxTool.zoom;
  }

  bool get allowBBoxEdit {
    final p = widget.policy;
    if (isDesktopLike && p != ToolPolicy.enforced) return true;
    return effectiveTool == BBoxTool.bboxs;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: LayoutBuilder(
        builder: (context, c) {
          final viewSize = Size(c.maxWidth, c.maxHeight);
          _ctrl.viewSize = viewSize;

          return ValueListenableBuilder<BBoxTool>(
            valueListenable: widget.controller!.bBoxTool,
            builder: (context, value, child) {

              return InteractiveViewer(
                maxScale: 4,
                minScale: 1,
                scaleEnabled: allowZoom,
                panEnabled: allowZoom,
                transformationController: _tc,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // VIDEO
                    MJPEGStreamScreen(
                      streamUrl: widget.stream,
                      borderRadius: 0,
                      watermarkText: "Issel Code",
                      width: viewSize.width,
                      height: viewSize.height,
                      showLiveIcon: false,
                      showLogs: false,
                      blurSensitiveContent: false,
                      showWatermark: true,
                      onRetry: () => widget.onRetry?.call(),
                      onError: () {
                        cameraStreamError = true;
                        setState(() {});
                        widget.onStreamError?.call();
                      },
                      onStartCamera: () async {
                        cameraStreamError = false;
                        setState(() {});
                        widget.onStreamReady?.call();

                        // Disparamos la carga de boundings si el padre nos dio el callback
                        if (widget.onStreamReadyFutureBoundings != null) {
                          setState(() => _loadingInitial = true);
                          try {
                            final list = await widget.onStreamReadyFutureBoundings!(_ctrl.mapper);
                            _ctrl.setInitialBoxes(list);
                          } finally {
                            if (mounted) setState(() => _loadingInitial = false);
                          }
                        }
                      },
                    ),

                    // OVERLAY
                    if (!cameraStreamError && allowBBoxEdit)
                      ValueListenableBuilder<List<BBoxEntity>>(
                        valueListenable: _ctrl.boxes,
                        builder: (context, boxes, _) {
                          if (_loadingInitial) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return BBoxOverlay(
                            viewSize: viewSize,
                            camResolution: widget.camResolution,
                            // Usa el mismo controller que ya tienes para editar en memoria
                            controller: widget.controller!,
                            initialBoxes: boxes,
                            onCommitBox: (box, kind, commitOrigin) async {
                              if (widget.logs) print("${kind.name}, ${commitOrigin.name}, ${box.toString()}");
                              await widget.onCommitBox?.call(box, kind, commitOrigin);
                            },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

