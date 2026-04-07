import 'package:turbo_promptable/workspace/abstracts/root/t_memory.dart';

abstract class TEvent extends TMemory {
  TEvent({
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
