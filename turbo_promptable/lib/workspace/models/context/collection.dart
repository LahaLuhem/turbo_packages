import 'package:turbo_promptable/workspace/models/root/context.dart';

class Collection extends Context {
  const Collection({
    required super.name,
    required this.items,
  });

  final List<String> items;
}
