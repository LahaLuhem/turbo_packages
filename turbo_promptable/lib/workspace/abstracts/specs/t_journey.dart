import 'package:turbo_promptable/workspace/abstracts/root/t_spec.dart';

abstract class TJourney extends TSpec {
  TJourney({
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
