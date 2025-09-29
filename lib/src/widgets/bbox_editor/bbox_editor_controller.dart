import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_python_prueba/src/widgets/bbox_editor/bbox_editor_enums.dart';
import 'bbox_fit_cover_mapper.dart';
import 'bbox_entity.dart';
import 'bbox_helpers.dart';

sealed class BBoxEvent { const BBoxEvent(); }
class BoxCreated extends BBoxEvent { final BBoxEntity box; const BoxCreated(this.box); }
class BoxUpdated extends BBoxEvent { final BBoxEntity box; const BoxUpdated(this.box); }
class BoxDeleted extends BBoxEvent { final int id; const BoxDeleted(this.id); }
class BoxesCleared extends BBoxEvent { const BoxesCleared(); }

class BBoxEditorController extends ChangeNotifier {
  // --- Tamaños y mapper
  late Size _viewSize;
  Size get viewSize => _viewSize;
  set viewSize(Size v) => _viewSize = v;
  late Size cameraResolution;

  // Herramienta seleccionada
  final ValueNotifier<BBoxTool> bBoxTool = ValueNotifier(BBoxTool.bboxs);
  void setTool(BBoxTool tool) => bBoxTool.value = tool;

  FitCoverMapper get mapper {
    assert(_viewSize.width > 0 && _viewSize.height > 0,
    'viewSize debe estar asignado antes de usar mapper');
    assert(cameraResolution.width > 0 && cameraResolution.height > 0,
    'cameraResolution debe estar asignado antes de usar mapper');
    return FitCoverMapper(_viewSize, cameraResolution);
  }

  // --- Estado reactivo de boxes
  final ValueNotifier<List<BBoxEntity>> boxes = ValueNotifier(const []);

  // --- Eventos (opcional si te sirven)
  final _events = StreamController<BBoxEvent>.broadcast();
  Stream<BBoxEvent> get events => _events.stream;

  // --- Hooks que antes vivían en MultiBBoxOverlayController
  VoidCallback? _ovClearAll;
  void Function(int id)? _ovRemove;
  void Function(BBoxEntity box)? _ovAdd;
  void Function(List<BBoxEntity> boxes)? _ovSetAll;

  /// Llamado por el overlay en su initState
  void attachOverlay({
    required VoidCallback clearAll,
    required void Function(int id) remove,
    required void Function(BBoxEntity box) add,
    required void Function(List<BBoxEntity> boxes) setAll,
  }) {
    _ovClearAll = clearAll;
    _ovRemove = remove;
    _ovAdd = add;
    _ovSetAll = setAll;
  }

  /// Llamado por el overlay en su dispose
  void detachOverlay() {
    _ovClearAll = null;
    _ovRemove = null;
    _ovAdd = null;
    _ovSetAll = null;
  }

  // --- API externa para el padre/negocio y también usada por el overlay

  void setInitialBoxes(List<BBoxEntity> list) {
    boxes.value = List.unmodifiable(list);
    _ovSetAll?.call(list); // notifica al overlay para sincronizar su buffer interno si tiene
    // (No emito evento aquí para evitar ruido si no lo necesitas)
  }

  void clearAll() {
    boxes.value = const [];
    _ovClearAll?.call();
    _events.add(const BoxesCleared());
  }

  void addBox(BBoxEntity b) {
    boxes.value = [...boxes.value, b];
    _ovAdd?.call(b);
    _events.add(BoxCreated(b));
  }

  void updateBox(BBoxEntity b) {
    final i = boxes.value.indexWhere((e) => e.id == b.id);
    if (i >= 0) {
      final l = [...boxes.value]..[i] = b;
      boxes.value = l;
      _events.add(BoxUpdated(b));
    }
    // El overlay se actualiza vía ValueListenableBuilder,
    // por lo que no es necesario llamar a un hook aquí.
  }

  void removeBox(int id) {
    boxes.value = boxes.value.where((e) => e.id != id).toList(growable: false);
    _ovRemove?.call(id);
    _events.add(BoxDeleted(id));
  }

  /// Helper genérico para modificar un box por id (p. ej. cambiar color, ángulo, etc.)
  void patchBox(int id, BBoxEntity Function(BBoxEntity old) updater) {
    final i = boxes.value.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final old = boxes.value[i];
    final updated = updater(old);
    final l = [...boxes.value]..[i] = updated;
    boxes.value = l;
    _events.add(BoxUpdated(updated));
  }

  /// Caso común: actualizar color y redibujar
  void updateColor(int id, Color color) {
    patchBox(id, (old) => old.copyWith(color: color));
  }

  @override
  void dispose() {
    boxes.dispose();
    _events.close();
    super.dispose();
  }
}
