import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/src/controllers/logic/bounding_controller.dart';
import 'package:flutter_python_prueba/src/controllers/logic/camera_controller.dart';
import 'package:flutter_python_prueba/src/model/bounding_model.dart';
import 'package:flutter_python_prueba/src/model/camera_model.dart';
import 'package:flutter_python_prueba/src/views/home_view.dart';
import 'package:provider/provider.dart';
import 'package:snap_layouts/snap_layouts.dart';
import 'package:window_manager/window_manager.dart';

import 'core/http/endpoints.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1366, 768),
    minimumSize: Size(1366, 768),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => CameraModel(),),
        Provider(create: (context) => BoundingModel(),),
        ChangeNotifierProvider(create: (context) => CameraController(cameraModel: context.read()),),
        ChangeNotifierProvider(create: (context) => BoundingController(boundingModel: context.read()),)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        builder: (context, child) {
          return Stack(
            children: [
              // const CustomTitleBar(),
              child!,
              SizedBox(
                height: 40,
                child: SnapLayoutsCaption()
              ),
            ],
          );
        },
        home: CamBBoxRotateView(
          base: Endpoint.base,
          frameW: 1920,
          frameH: 1080,
        ),
      ),
    );
  }
}
