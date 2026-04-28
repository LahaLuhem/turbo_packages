import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/extensions/t_list_extension.dart';
import 'package:turbo_firestore_api/typedefs/t_model_builder_def.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

// TODO(brian): Add option to create several lists with indexes, sort and filter options per list and to dispose them - always keeping all data in sync | 26/04/2026

class TModelDocs<DTO extends TWriteableId, MODEL extends TModel<DTO>> {
  const TModelDocs({
    required this.values,
    required Map<String, int> idMap,
    required this.modelBuilder,
  }) : _idMap = idMap;

  factory TModelDocs.empty({
    required TModelBuilderDef<DTO, MODEL> modelBuilder,
  }) => TModelDocs(
    values: [],
    idMap: {},
    modelBuilder: modelBuilder,
  );

  factory TModelDocs.fromDtos({
    required List<DTO> dtos,
    required TModelBuilderDef<DTO, MODEL> modelBuilder,
  }) {
    final (values, idMap) = dtos.toIdDocsModelsMap<MODEL>(
      idBuilder: (dto) => dto.id,
      modelBuilder: modelBuilder,
    );
    return TModelDocs<DTO, MODEL>(
      values: values,
      idMap: idMap,
      modelBuilder: modelBuilder,
    );
  }

  final List<MODEL> values;
  final TModelBuilderDef<DTO, MODEL> modelBuilder;
  final Map<String, int> _idMap;

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  bool get isNotEmpty => values.isNotEmpty;
  bool get isEmpty => values.isEmpty;
  bool exists(String id) => _idMap.containsKey(id);
  DTO? getDto(String? id) {
    final index = _idMap[id];
    if (index == null) return null;
    return values[index].dto;
  }

  MODEL? get(String? id) {
    final index = _idMap[id];
    if (index == null) return null;
    return values[index];
  }

  bool remove(String id) {
    final index = _idMap[id];
    if (index == null) return false;
    values.removeAt(index);
    _idMap.remove(id);
    for (int i = index; i < values.length; i++) {
      _idMap[values[i].id] = i;
    }
    return true;
  }

  DTO updateDto(DTO newValue) {
    final index = _idMap[newValue.id];
    if (index == null) {
      values.add(modelBuilder(newValue));
      _idMap[newValue.id] = values.length - 1;
      return newValue;
    }
    final model = values[index];
    values[index] = model.copyWith(
      dto: newValue,
    );
    return newValue;
  }

  MODEL update(MODEL newValue) {
    final index = _idMap[newValue.id];
    if (index == null) {
      values.add(newValue);
      _idMap[newValue.id] = values.length - 1;
      return newValue;
    }
    values[index] = newValue;
    return newValue;
  }

  int get length => values.length;
}
