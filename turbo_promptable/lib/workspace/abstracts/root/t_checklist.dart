import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

abstract class TChecklist extends TPromptable {
  TChecklist({
    required super.name,
    super.renderType = TRenderType.embed,
    super.bodyType = TBodyType.md,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
    required this.items,
  });

  final List<String> items;
}
