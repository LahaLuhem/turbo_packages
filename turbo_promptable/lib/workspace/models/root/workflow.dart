import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';
import 'package:turbo_promptable/workspace/models/root/tool_set.dart';

part 'workflow.g.dart';

/// An ordered sequence of [Step]s that define a process.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Workflow extends TPromptable {
  const Workflow({
    required super.name,
    super.metaData,
    required this.steps,
    required this.endGoal,
    this.instructions,
    this.tools,
    this.toolSets,
  });

  final List<Step> steps;
  final EndGoal endGoal;
  final List<Instruction>? instructions;
  final List<Tool>? tools;
  final List<ToolSet>? toolSets;

  factory Workflow.fromJson(Map<String, dynamic> json) => _$WorkflowFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WorkflowToJson(this);
}
