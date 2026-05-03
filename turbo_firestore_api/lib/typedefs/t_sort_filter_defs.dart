import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/models/t_sort_filtered_list.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TFilterPredicate<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    bool Function(MODEL model);
typedef TSortPredicate<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    int Function(MODEL a, MODEL b);
typedef TSortFilteredListsMap<
  DTO extends TWriteableId,
  MODEL extends TModel<DTO>
> = Map<Object, TSortFilteredList<DTO, MODEL>>;
