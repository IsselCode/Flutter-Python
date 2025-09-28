import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/core/http/endpoints.dart';
import 'package:flutter_python_prueba/src/controllers/logic/camera_controller.dart';
import 'package:flutter_python_prueba/src/widgets/bbox_editor.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {



  @override
  Widget build(BuildContext context) {
    CameraController camCtrl = context.read();

    return BBoxEditor(
      stream: camCtrl.streamCamera(),
      frameH: 1080,
      frameW: 1920,
    );
  }


}
