import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

abstract class TBox extends TPromptable {
  TBox({
    super.metaData,
    required super.name,
  });
}
