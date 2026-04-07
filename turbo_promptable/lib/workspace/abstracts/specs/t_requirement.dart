import 'package:turbo_promptable/workspace/abstracts/root/t_spec.dart';

export 'package:turbo_promptable/workspace/abstracts/root/t_spec.dart';

abstract class TRequirement extends TSpec {
  TRequirement({
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
