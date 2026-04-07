import 'package:turbo_promptable/workspace/abstracts/root/t_context.dart';

abstract class TActor extends TContext {
  TActor({
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
