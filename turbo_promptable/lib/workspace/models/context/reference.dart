import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

abstract class Reference extends TPromptable {
  Reference({
    required super.name,
    super.metaData,
    super.config,
  });
}
