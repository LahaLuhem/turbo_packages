import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

/// Extension on [List] that provides utility methods for working with lists in the context of Turbo Firestore.
extension TDtoListExtensionExtension<
  DTO extends TWriteableId,
  MODEL extends TModel<DTO>
>
    on List<DTO> {
  Map<String, DTO> toDtoIdMap([String Function(DTO writeable)? idBuilder]) {
    final _idBuilder = idBuilder ?? (writeable) => writeable.id;
    final map = <String, DTO>{};
    for (final element in this) {
      map[_idBuilder(element)] = element;
    }
    return map;
  }

  Map<String, int> toDtoIdIndexMap([
    String Function(DTO writeable)? idBuilder,
  ]) {
    final _idBuilder = idBuilder ?? (writeable) => writeable.id;
    final map = <String, int>{};
    for (int index = 0; index < length; index++) {
      final element = this[index];
      map[_idBuilder(element)] = index;
    }
    return map;
  }

  (List<MODEL> models, Map<String, int> idMap)
  toIdDocsModelsMap<MODEL extends TModel<DTO>>({
    required String Function(DTO dto) idBuilder,
    required MODEL Function(DTO dto) modelBuilder,
  }) {
    final _idBuilder = idBuilder;
    final models = <MODEL>[];
    final idMap = <String, int>{};
    for (int index = 0; index < length; index++) {
      final element = this[index];
      idMap[_idBuilder(element)] = index;
      models.add(modelBuilder(element));
    }
    return (models, idMap);
  }
}

/// Extension on [List] that provides utility methods for working with lists in the context of Turbo Firestore.
extension TModelListExtensionExtension<
  DTO extends TWriteableId,
  MODEL extends TModel<DTO>
>
    on List<MODEL> {
  Map<String, MODEL> toModelIdMap([String Function(MODEL model)? idBuilder]) {
    final _idBuilder = idBuilder ?? (model) => model.id;
    final map = <String, MODEL>{};
    for (final element in this) {
      map[_idBuilder(element)] = element;
    }
    return map;
  }
}
