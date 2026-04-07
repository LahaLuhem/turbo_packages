import 'package:turbo_promptable/workspace/abstracts/root/t_instruction.dart';

abstract class TSkill extends TInstruction {
  TSkill({
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
