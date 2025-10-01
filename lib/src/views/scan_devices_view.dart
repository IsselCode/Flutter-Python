import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/src/clean_features/entities/device_entity.dart';
import 'package:flutter_python_prueba/src/controllers/logic/device_controller.dart';
import 'package:flutter_python_prueba/src/views/home_view.dart';
import 'package:flutter_python_prueba/src/widgets/scan_pulse_button_widget.dart';
import 'package:provider/provider.dart';

class ScanDevicesView extends StatefulWidget {
  const ScanDevicesView({super.key});

  @override
  State<ScanDevicesView> createState() => _ScanDevicesViewState();
}

class _ScanDevicesViewState extends State<ScanDevicesView> {
  late Future<List<DeviceEntity>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    DeviceController deviceController = context.read();
    _devicesFuture = deviceController.discoverWithNsd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
      
          final double bigSize = h * 0.85;
          final double smallSize = h * 0.65;
      
          return FutureBuilder<List<DeviceEntity>>(
            future: _devicesFuture,
            builder: (context, snapshot) {
              final bool ready = snapshot.connectionState == ConnectionState.done;
              final devices = snapshot.data ?? const <DeviceEntity>[];
              final int count = devices.length;
      
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: ready ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeInOutCubic,
                builder: (context, t, _) {
                  // 1. División animada 100% -> 50% izquierda
                  final double split = 1.0 - 0.5 * t;
                  // 2. Tamaño del botón 0.8h -> 0.5h
                  final double btnSize = bigSize + (smallSize - bigSize) * t;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ▶️ Panel derecho: llena desde 'left' hacia la derecha
                      Positioned.fill(
                        left: w * split,
                        child: Opacity(
                          opacity: t,
                          child: _RightPanel(devices: devices, loading: !ready),
                        ),
                      ),

                      // ◀️ Zona izquierda EXACTA: ancho = w * split
                      // (en Positioned no hay 'width', se calcula con left+right)
                      Positioned(
                        left: 0,
                        right: w * (1 - split), // => width = w - 0 - right = w * split
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: ScanPulseButton(
                            size: btnSize,
                            avatarColor: const Color(0xFF0F52FF),
                            icon: Icons.computer_outlined,
                            active: !ready,
                            quantity: count,
                            onTap: () {},
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  final List<DeviceEntity> devices;
  final bool loading;

  const _RightPanel({required this.devices, required this.loading});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    // Placeholder de lista: personalízalo como quieras
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (devices.isEmpty) {
      return const Center(
        child: Text('Sin dispositivos', style: TextStyle(fontSize: 16)),
      );
    }
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Dispositivos Encontrados",
              style: textTheme.titleLarge,
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: devices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12,),
                itemBuilder: (context, i) {
                  final d = devices[i];
                  return Material(
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      tileColor: colorScheme.surface,
                      leading: const Icon(Icons.devices),
                      title: Text(d.host),
                      subtitle: Text("${d.name}${d.port}"),
                      onTap: () => setDevice(context, d),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setDevice(BuildContext context, DeviceEntity device) {
    DeviceController deviceController = context.read();
    deviceController.device = device;
  }
}
