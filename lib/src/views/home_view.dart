import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/core/utils/random_hex_color.dart';
import 'package:flutter_python_prueba/src/controllers/logic/bounding_controller.dart';
import 'package:flutter_python_prueba/src/controllers/logic/camera_controller.dart';
import 'package:flutter_python_prueba/src/widgets/bbox_editor/bbox_editor.dart';
import 'package:flutter_python_prueba/src/widgets/bbox_editor/bbox_editor_controller.dart';
import 'package:flutter_python_prueba/src/widgets/bbox_editor/bbox_entity.dart';
import 'package:provider/provider.dart';

import '../widgets/bbox_editor/bbox_editor_enums.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {


  BBoxEditorController controller = BBoxEditorController();
  late Future<Size> _startCamera;

  @override
  void initState() {
    super.initState();
    CameraController camCtrl = context.read();
    _startCamera = camCtrl.startCamera();
  }


  @override
  Widget build(BuildContext context) {
    CameraController camCtrl = context.read();
    BoundingController bCtrl = context.read();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (controller.bBoxTool.value == BBoxTool.zoom){
            controller.setTool(BBoxTool.bboxs);
          } else {
            controller.setTool(BBoxTool.zoom);
          }
          setState(() {});
        },
        child: Icon(controller.bBoxTool.value == BBoxTool.zoom ? Icons.zoom_out_map_outlined : Icons.edit_outlined),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _startCamera,
          builder: (context, snapshot) {
        
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text("Cargando Camara"),);
            }

            Size size = snapshot.data!;
        
            return BBoxEditor(
              stream: camCtrl.streamCamera(),
              onStreamReadyFutureBoundings: (mapper) => bCtrl.getBBoxes(mapper),
              controller: controller,
              camResolution: size,
              onCommitBox: (box, kind, commitOrigin) async {
                switch (kind) {
                  case CommitKind.create:
                    await bCtrl.sendBBoxOBB(box!);
                    break;
                  case CommitKind.update:
                    await bCtrl.updateBBoxById(box!);
                    break;
                  case CommitKind.delete:
                    await bCtrl.deleteBBoxById(box!.id);
                    break;
                  case CommitKind.selected:
                  case CommitKind.unselected:
                }
              },
              onStreamReady: () {

              },
              onRetry: () {
                CameraController camCtrl = context.read();
                _startCamera = camCtrl.startCamera();
              },
              onStreamError: () {

              },
            );
        
          },
        ),
      ),
    );
  }


}
