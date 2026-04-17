import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/root/input.dart';
import 'package:turbo_promptable/workspace/models/root/output.dart';
import 'package:turbo_promptable/workspace/models/root/workflow.dart';

part 'activity.g.dart';

/// A discrete unit of work with an [input], a [workflow], and an [output].
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Activity extends TPromptable {
  const Activity({
    required super.name,
    required this.workflow,
    super.metaData,
    this.role,
  });

  final Role? role;
  final Workflow workflow;

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
