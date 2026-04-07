import 'package:turbo_promptable/workspace/abstracts/root/tool.dart';

abstract class TApi extends Tool {
  TApi({
    required super.name,
    super.metaData,
    super.config,
  });
}
