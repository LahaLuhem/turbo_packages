import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

 class Checklist extends TPromptable {
  Checklist({
    required super.name,
    super.config,
    super.metaData,
    required this.items,
  });

  final List<String> items;
}
