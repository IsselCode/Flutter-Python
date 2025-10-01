import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/core/app/theme.dart';
import 'package:flutter_python_prueba/core/services/navigation_service.dart';
import 'package:flutter_python_prueba/src/controllers/logic/bounding_controller.dart';
import 'package:flutter_python_prueba/src/controllers/logic/camera_controller.dart';
import 'package:flutter_python_prueba/src/controllers/logic/device_controller.dart';
import 'package:flutter_python_prueba/src/model/bounding_model.dart';
import 'package:flutter_python_prueba/src/model/camera_model.dart';
import 'package:flutter_python_prueba/src/views/home_view.dart';
import 'package:flutter_python_prueba/src/views/scan_devices_view.dart';
import 'package:provider/provider.dart';
import 'package:snap_layouts/snap_layouts.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

import 'inject_container.dart';

/// flutter_bbox_editor
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await injectContainer();

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
        ChangeNotifierProvider(create: (context) => DeviceController(
          model: locator(),
          navigationService: locator()
        ),),
        ChangeNotifierProvider(create: (context) => CameraController(cameraModel: locator()),),
        ChangeNotifierProvider(create: (context) => BoundingController(boundingModel: locator()),)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        navigatorKey: locator<NavigationService>().navigatorKey,
        theme: darkTheme,
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
        home: ScanDevicesView(),
      ),
    );
  }
}
