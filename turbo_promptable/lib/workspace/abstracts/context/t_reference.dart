import 'package:turbo_promptable/workspace/abstracts/root/t_context.dart';

abstract class TReference extends TPromptable {
  TReference({
    required super.name,
    super.renderType = TRenderType.embed,
    super.bodyType = TBodyType.md,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
  });
}
