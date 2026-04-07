import 'package:json_annotation/json_annotation.dart';

import '../../shared/abstracts/turbo_promptable.dart';

part 'end_goal_dto.g.dart';

/// Represents an end goal in the Pew Pew Plaza hierarchy.
///
/// Defines the desired outcome with acceptance criteria and constraints.
@JsonSerializable(includeIfNull: true, explicitToJson: true)
class GoalDto extends TurboPromptable {
  /// Creates an [GoalDto] with the given properties.
  GoalDto({
    this.acceptanceCriteria,
    this.constraints,
    super.metaData,
  });

  final List<String>? acceptanceCriteria;
  final List<String>? constraints;

  static const fromJsonFactory = _$EndGoalDtoFromJson;
  factory GoalDto.fromJson(Map<String, dynamic> json) =>
      _$EndGoalDtoFromJson(json);
  static const toJsonFactory = _$EndGoalDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$EndGoalDtoToJson(this);

  @override
  String toString() =>
      'EndGoalDto{acceptanceCriteria: $acceptanceCriteria, constraints: $constraints}';
}
