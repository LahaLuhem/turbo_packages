import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'goal.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Goal extends TPromptable {
  const Goal({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GoalToJson(this);
}
