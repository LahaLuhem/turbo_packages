import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'non_goals.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class NonGoals extends Checklist {
  NonGoals({
    required super.name,
    required super.items,
    super.config,
  });

  static final NonGoals Function(Map<String, dynamic> json) fromJsonFactory =
      _$NonGoalsFromJson;
  factory NonGoals.fromJson(Map<String, dynamic> json) =>
      _$NonGoalsFromJson(json);
  static final Map<String, dynamic> Function(NonGoals value) toJsonFactory =
      _$NonGoalsToJson;
  @override
  Map<String, dynamic> toJson() => _$NonGoalsToJson(this);
}
