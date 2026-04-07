import 'package:turbo_promptable/workspace/abstracts/root/t_context.dart';

abstract class TConcept extends TContext {
  TConcept({
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
