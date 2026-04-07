import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

abstract class TBox extends TPromptable {
  TBox({
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
