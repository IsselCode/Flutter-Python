import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/src/controllers/logic/bounding_controller.dart';
import 'package:flutter_python_prueba/src/controllers/logic/camera_controller.dart';
import 'package:flutter_python_prueba/src/model/bounding_model.dart';
import 'package:flutter_python_prueba/src/model/camera_model.dart';
import 'package:flutter_python_prueba/src/views/home_view.dart';
import 'package:flutter_python_prueba/src/widgets/zoom_test/zoom_test_view.dart';
import 'package:provider/provider.dart';
import 'package:snap_layouts/snap_layouts.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'core/http/endpoints.dart';

/// flutter_bbox_editor
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      fullScreen: false,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

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
        home: HomeView(),
      ),
    );
  }
}
