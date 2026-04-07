import 'package:turbo_promptable/workspace/abstracts/root/t_tool.dart';

abstract class TApi extends TTool {
  TApi({
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
