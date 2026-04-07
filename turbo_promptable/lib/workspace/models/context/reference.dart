import 'package:turbo_promptable/workspace/abstracts/root/context.dart';

abstract class Reference extends TPromptable {
  Reference({
    required super.name,
    super.metaData,
    super.config,
  });
}
