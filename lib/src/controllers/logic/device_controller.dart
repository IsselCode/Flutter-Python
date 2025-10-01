import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/core/services/navigation_service.dart';
import 'package:flutter_python_prueba/src/clean_features/entities/device_entity.dart';
import 'package:flutter_python_prueba/src/model/device_model.dart';
import 'package:flutter_python_prueba/src/views/home_view.dart';

class DeviceController extends ChangeNotifier {

  DeviceModel model;
  NavigationService navigationService;

  DeviceController({
    required this.model,
    required this.navigationService,
  });

  DeviceEntity? _device;
  DeviceEntity? get device => _device;
  set device(DeviceEntity? value) {
    _device = value;
    navigationService.navigateAndReplace(HomeView());
  }

  Future<List<DeviceEntity>> discoverWithNsd() => model.discoverWithNsd();

}