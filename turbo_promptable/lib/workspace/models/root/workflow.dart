import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/workflows/step.dart';

part 'workflow.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Workflow extends TPromptable {
  const Workflow({
    required super.name,
    super.metaData,
    super.config,
    required this.steps,
  });

  final List<Step> steps;

  factory Workflow.fromJson(Map<String, dynamic> json) =>
      _$WorkflowFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WorkflowToJson(this);
}
