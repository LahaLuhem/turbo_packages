import 'package:turbo_promptable/workspace/abstracts/specs/t_requirement.dart';

abstract class TNFR extends TRequirement {
  TNFR({
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
