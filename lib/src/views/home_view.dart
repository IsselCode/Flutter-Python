import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/core/http/endpoints.dart';
import 'package:flutter_python_prueba/src/controllers/logic/bounding_controller.dart';
import 'package:flutter_python_prueba/src/controllers/logic/camera_controller.dart';
import 'package:flutter_python_prueba/src/widgets/bbox_editor/bbox_editor.dart';
import 'package:flutter_python_prueba/src/widgets/bbox_editor/bbox_editor_controller.dart';
import 'package:provider/provider.dart';

import '../widgets/bbox_editor/bbox_editor_enums.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {


  BBoxEditorController controller = BBoxEditorController();
  late Future<void> _startCamera;

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
        onPressed: () {
          // print(controller.boxes.value);
          // print(controller.boxes.value.first.color);
          // int id = controller.boxes.value.first.id;
          // controller.updateColor(id, Colors.green);
          controller.clearAll();
        },
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _startCamera,
          builder: (context, snapshot) {
        
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text("Cargando Camara"),);
            }
        
            return BBoxEditor(
              stream: camCtrl.streamCamera(),
              onStreamReadyFutureBoundings: (mapper) => bCtrl.getBBoxes(mapper),
              controller: controller,
              camResolution: Size(1920, 1080),
              onCommitBox: (box, kind) async {
                switch (kind) {
                  case CommitKind.create:
                    print("Creado");
                    break;
                  case CommitKind.update:
                    print("Actualizado");
                    break;
                  case CommitKind.delete:
                    print("Eliminado");
                    break;
                }
              },
              onStreamReady: () {},
              onRetry: () {},
              onStreamError: () {},
            );
        
          },
        ),
      ),
    );
  }


}
