import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'non_goals.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class NonGoals extends Checklist {
  const NonGoals({
    required super.name,
    required super.items,
  });

  factory NonGoals.fromJson(Map<String, dynamic> json) =>
      _$NonGoalsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NonGoalsToJson(this);
}
