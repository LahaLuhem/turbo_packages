import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/root/input.dart';
import 'package:turbo_promptable/workspace/models/root/output.dart';
import 'package:turbo_promptable/workspace/models/root/workflow.dart';

part 'activity.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Activity extends TPromptable {
  const Activity({
    required super.name,
    required this.input,
    required this.output,
    required this.workflow,
    super.config,
    super.metaData,
  });

  final Input input;
  final Workflow workflow;
  final Output output;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
