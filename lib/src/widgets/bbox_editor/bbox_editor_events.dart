import 'package:flutter_python_prueba/src/widgets/bbox_editor/bbox_editor_enums.dart';

import 'bbox_entity.dart';

sealed class BBoxEvent {
  final CommitOrigin origin;
  const BBoxEvent({required this.origin});
}

class BoxCreated extends BBoxEvent {
  final BBoxEntity box;
  const BoxCreated({required this.box, required super.origin});
}

class BoxUpdated extends BBoxEvent {
  final BBoxEntity box;
  const BoxUpdated({required this.box, required super.origin});
}

class BoxDeleted extends BBoxEvent {
  final int id;
  const BoxDeleted({required this.id, required super.origin});
}

class BoxesCleared extends BBoxEvent { const BoxesCleared({required super.origin}); }