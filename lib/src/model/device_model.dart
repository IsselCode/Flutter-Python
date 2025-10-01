import 'dart:convert';

import 'package:flutter_python_prueba/src/clean_features/entities/device_entity.dart';
import 'package:nsd/nsd.dart';

class DeviceModel {

  Future<List<DeviceEntity>> discoverWithNsd() async {

    try {

      final discovery = await startDiscovery('_http._tcp');
      final out = <DeviceEntity>[];

      discovery.addServiceListener((service, status) async {
        final resolved = await resolve(service);
        final host = resolved.host;   // puede ser hostname; nsd resuelve IP internamente
        final port = resolved.port ?? 80;
        final Map<String, String> txt = {
          for (final entry in (resolved.txt ?? {}).entries)
            entry.key: (entry.value is List<int>)
                ? utf8.decode(entry.value as List<int>)
                : entry.value.toString(),
        };
        out.add(DeviceEntity(resolved.name ?? '', host ?? '', port, txt));
      });

      // Espera ~3–5 s a que aparezcan
      await Future.delayed(const Duration(seconds: 5));
      await stopDiscovery(discovery);
      return out;
    } catch (e) {
      print(e.toString());
      throw UnimplementedError();
    }

  }

}