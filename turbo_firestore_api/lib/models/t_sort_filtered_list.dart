import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/typedefs/t_sort_filter_defs.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

class TSortFilteredList<DTO extends TWriteableId, MODEL extends TModel<DTO>> {
  TSortFilteredList({
    this.filter,
    this.sort,
  });

  final TFilterPredicate<DTO, MODEL>? filter;
  final TSortPredicate<DTO, MODEL>? sort;

  List<MODEL> _values = [];
  List<MODEL> get values => _values;

  List<MODEL> apply(Iterable<MODEL> models) {
    final filtered = filter == null
        ? models.toList()
        : models.where(filter!).toList();
    if (sort != null) {
      filtered.sort(sort);
    }
    _values = filtered;
    return _values;
  }

  List<MODEL> add(MODEL model) {
    if (filter?.call(model) ?? true) {
      _values.add(model);
      if (sort != null) {
        _values.sort(sort);
      }
    }
    return _values;
  }

  List<MODEL> remove(String id) {
    _values.removeWhere((dto) => dto.id == id);
    return _values;
  }
}
