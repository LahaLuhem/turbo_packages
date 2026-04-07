import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

abstract class Issue extends TPromptable {
  Issue({
    required super.name,
    super.description,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
  });
}
