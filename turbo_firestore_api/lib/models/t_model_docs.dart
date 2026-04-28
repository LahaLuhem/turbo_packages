import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/models/t_sort_filtered_list.dart';
import 'package:turbo_firestore_api/typedefs/t_id_map_def.dart';
import 'package:turbo_firestore_api/typedefs/t_model_builder_def.dart';
import 'package:turbo_firestore_api/typedefs/t_sort_filter_defs.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

// TODO(brian): Add option to create several lists with indexes, sort and filter options per list and to dispose them - always keeping all data in sync | 26/04/2026

class TModelDocs<DTO extends TWriteableId, MODEL extends TModel<DTO>> {
  const TModelDocs({
    required TIdMapDef<MODEL> idMap,
    required TSortFilteredListsMap<DTO, MODEL> sortFilteredListsMap,
    required this.modelBuilder,
  }) : _sortFilteredListsMap = sortFilteredListsMap,
       _idMap = idMap;

  factory TModelDocs.empty({
    required TModelBuilderDef<DTO, MODEL> modelBuilder,
  }) => TModelDocs(
    idMap: {},
    modelBuilder: modelBuilder,
    sortFilteredListsMap: {},
  );

  factory TModelDocs.fromDtos({
    required List<DTO> dtos,
    required TModelBuilderDef<DTO, MODEL> modelBuilder,
    TSortFilteredListsMap<DTO, MODEL>? sortFilteredListsMap,
  }) {
    final idMap = <String, MODEL>{};
    final models = <MODEL>[];
    for (final dto in dtos) {
      final model = modelBuilder(dto);
      models.add(model);
      idMap[model.id] = model;
    }
    final pSortFilteredListsMap = sortFilteredListsMap ?? <String, TSortFilteredList<DTO, MODEL>>{};
    for (final sortFilteredList in pSortFilteredListsMap.values) {
      sortFilteredList.apply(models);
    }
    return TModelDocs<DTO, MODEL>(
      idMap: idMap,
      modelBuilder: modelBuilder,
      sortFilteredListsMap: pSortFilteredListsMap,
    );
  }

  final TModelBuilderDef<DTO, MODEL> modelBuilder;
  final TIdMapDef<MODEL> _idMap;
  final TSortFilteredListsMap<DTO, MODEL> _sortFilteredListsMap;

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  bool get isNotEmpty => _idMap.isNotEmpty;
  bool get isEmpty => _idMap.isEmpty;
  bool exists(String id) => _idMap.containsKey(id);
  DTO? dto(String? id) => _idMap[id]?.dto;
  MODEL? get(String? id) => _idMap[id];
  MODEL? remove(String id) => _idMap.remove(id);
  Iterable<String> get ids => _idMap.keys;
  Iterable<MODEL> get models => _idMap.values;
  List<MODEL> getList(Object? id) => _sortFilteredListsMap[id]?.values ?? [];

  List<MODEL> upsertDtos(Iterable<DTO> newValues) {
    final models = <MODEL>[];
    for (final newValue in newValues) {
      final model = upsertDto(newValue);
      models.add(model);
      for (final sortFilteredList in _sortFilteredListsMap.values) {
        sortFilteredList.add(model);
      }
    }
    return models;
  }

  List<MODEL> upsertValues(Iterable<MODEL> newValues) {
    final models = <MODEL>[];
    for (final newValue in newValues) {
      final model = upsertValue(newValue);
      models.add(model);
      for (final sortFilteredList in _sortFilteredListsMap.values) {
        sortFilteredList.add(model);
      }
    }
    return models;
  }

  MODEL upsertDto(DTO newValue) {
    final model = upsertValue(modelBuilder(newValue));
    for (final sortFilteredList in _sortFilteredListsMap.values) {
      sortFilteredList.add(model);
    }
    return model;
  }

  MODEL upsertValue(MODEL newValue) {
    _idMap[newValue.id] = newValue;
    return newValue;
  }

  List<MODEL> addList({
    required Object id,
    required TSortFilteredList<DTO, MODEL> sortFilteredList,
    bool doInitialApply = true,
  }) {
    if (doInitialApply) {
      sortFilteredList.apply(models);
    }
    _sortFilteredListsMap[id] = sortFilteredList;
    return sortFilteredList.values;
  }

  List<MODEL> removeList(Object id) => _sortFilteredListsMap.remove(id)?.values ?? [];

  int get length => _idMap.length;
}
