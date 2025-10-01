import 'package:flutter_python_prueba/core/services/navigation_service.dart';
import 'package:flutter_python_prueba/core/services/toast_service.dart';
import 'package:flutter_python_prueba/src/model/bounding_model.dart';
import 'package:flutter_python_prueba/src/model/camera_model.dart';
import 'package:flutter_python_prueba/src/model/device_model.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> injectContainer() async {

  locator.registerLazySingleton(() => ToastService(),);
  locator.registerLazySingleton(() => NavigationService(),);

  locator.registerLazySingleton(() => DeviceModel(),);
  locator.registerLazySingleton(() => BoundingModel());
  locator.registerLazySingleton(() => CameraModel());

}