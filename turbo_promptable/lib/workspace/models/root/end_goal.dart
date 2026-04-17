import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';
import 'package:turbo_promptable/workspace/models/checklists/acceptance_criteria.dart';
import 'package:turbo_promptable/workspace/models/checklists/constraints.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/root/goal.dart';

part 'end_goal.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class EndGoal extends Goal {
  const EndGoal(
    super.value, {
    this.acceptanceCriteria,
    this.constraints,
    super.metaData,
  }) : super(
         name: 'End Goal',
       );

  final AcceptanceCriteria? acceptanceCriteria;
  final Constraints? constraints;

  factory EndGoal.fromJson(Map<String, dynamic> json) => _$EndGoalFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$EndGoalToJson(this);
}
