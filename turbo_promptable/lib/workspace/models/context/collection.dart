import 'package:turbo_promptable/workspace/models/root/context.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

class Collection extends Context {
  const Collection({
    required super.name,
    super.metaData,
    required this.items,
  });

  final List<String> items;
}
