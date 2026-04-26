import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

/// Extension on [List] that provides utility methods for working with lists in the context of Turbo Firestore.
extension TListExtensionExtension<WRITEABLE extends TWriteableId> on List<WRITEABLE> {
  Map<String, WRITEABLE> toIdMap([String Function(WRITEABLE writeable)? idBuilder]) {
    final _idBuilder = idBuilder ?? (writeable) => writeable.id;
    final map = <String, WRITEABLE>{};
    for (final element in this) {
      map[_idBuilder(element)] = element;
    }
    return map;
  }

  Map<String, int> toIdIndexMap([
    String Function(WRITEABLE writeable)? idBuilder,
  ]) {
    final _idBuilder = idBuilder ?? (writeable) => writeable.id;
    final map = <String, int>{};
    for (int index = 0; index < length; index++) {
      final element = this[index];
      map[_idBuilder(element)] = index;
    }
    return map;
  }
}
