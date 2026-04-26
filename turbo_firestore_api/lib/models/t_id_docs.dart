import 'package:turbo_firestore_api/extensions/t_list_extension.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

class TIdDocs<T extends TWriteableId> {
  TIdDocs(this.values) : _idMap = values.toIdIndexMap();

  final List<T> values;
  final Map<String, int> _idMap;

  TIdDocs.empty() : values = [], _idMap = {};

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  bool get isNotEmpty => values.isNotEmpty;
  bool get isEmpty => values.isEmpty;
  bool exists(String id) => _idMap.containsKey(id);
  T? get(String? id) {
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

  T update(T newValue) {
    final index = _idMap[newValue.id];
    if (index == null) {
      values.add(newValue);
      _idMap[newValue.id] = values.length - 1;
      return newValue;
    }
    values[index] = newValue;
    return newValue;
  }
}
