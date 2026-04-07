import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

abstract class TTemplate extends TPromptable {
  TTemplate({
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
