import 'package:turbo_promptable/workspace/models/root/context.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

/// [T] is typically a [TWriteable]; items are encoded with [TWriteable.toJson].
class Collection<T extends Object> extends Context {
  const Collection({
    required super.name,
    super.config,
    super.metaData,
    required this.items,
  });

  final List<T> items;

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['items'] = items.map(_encodeItem).toList();
    return map;
  }

  Object? _encodeItem(T item) {
    if (item is TWriteable) {
      return item.toJson();
    }
    return item;
  }
}
