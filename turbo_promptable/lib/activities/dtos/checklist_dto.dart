
import 'package:json_annotation/json_annotation.dart';

import '../../shared/abstracts/turbo_promptable.dart';

part 'end_goal_dto.g.dart';

/// Represents an end goal in the Pew Pew Plaza hierarchy.
///
/// Defines the desired outcome with acceptance criteria and constraints.
@JsonSerializable(includeIfNull: true, explicitToJson: true)
class ChecklistDto extends TurboPromptable {
  /// Creates an [ChecklistDto] with the given properties.
  ChecklistDto({
    super.metaData,
  });



  static const fromJsonFactory = _$ChecklistDtoFromJson;
  factory ChecklistDto.fromJson(Map<String, dynamic> json) => _$ChecklistDtoFromJson(json);
  static const toJsonFactory = _$ChecklistDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$ChecklistDtoToJson(this);

}
