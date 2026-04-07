import 'package:turbo_promptable/workspace/abstracts/root/context.dart';

abstract class Collection<T extends Object> extends Context {
  Collection({
    required super.name,
    super.config,
    super.metaData,
    required this.items,
  });

  final List<T> items;
}
