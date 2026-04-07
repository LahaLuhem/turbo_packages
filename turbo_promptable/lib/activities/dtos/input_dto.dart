import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/activities/dtos/checklist_dto.dart';
import 'package:turbo_promptable/activities/dtos/context_dto.dart';
import 'package:turbo_promptable/activities/dtos/goal_dto.dart';
import 'package:turbo_promptable/sources/inputs/dtos/issue_dto.dart';
import 'package:turbo_promptable/sources/inputs/dtos/spec_dto.dart';

import '../../shared/abstracts/turbo_promptable.dart';

part 'end_goal_dto.g.dart';

/// Represents an end goal in the Pew Pew Plaza hierarchy.
///
/// Defines the desired outcome with acceptance criteria and constraints.
@JsonSerializable(includeIfNull: true, explicitToJson: true)
class InputDto extends TurboPromptable {
  /// Creates an [InputDto] with the given properties.
  InputDto({
    super.metaData,
  });

  final String request;
  final List<ChecklistDto>? checklists;
  final List<SpecDto>? specs;
  final List<IssueDto>? issues;
  final List<GoalDto>? goals;
  final List<ContextDto>? context;



  static const fromJsonFactory = _$InputDtoFromJson;
  factory InputDto.fromJson(Map<String, dynamic> json) => _$InputDtoFromJson(json);
  static const toJsonFactory = _$InputDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$InputDtoToJson(this);

}
