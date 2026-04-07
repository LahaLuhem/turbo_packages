import 'package:turbo_promptable/workspace/abstracts/root/t_checklist.dart';

abstract class TNonGoals extends TChecklist {
  TNonGoals({
    required super.name,
    super.renderType = TRenderType.embed,
    super.bodyType = TBodyType.md,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
    required super.items,
  });
}
