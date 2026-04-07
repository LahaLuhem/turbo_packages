import 'package:turbo_promptable/workspace/abstracts/checklists/acceptance_criteria.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_template.dart';

 class Output extends TPromptable {
  Output({
    required super.name,
    super.metaData,
    this.acceptanceCriteria,
    this.template,
  });

  final Template? template;
  final AcceptanceCriteria? acceptanceCriteria;
}
