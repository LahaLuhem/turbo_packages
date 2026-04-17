import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'non_goals.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class NonGoals extends Checklist {
  const NonGoals(List<String> items)
    : super(
        name: 'Non Goals',
        items: items,
      );

  factory NonGoals.fromJson(Map<String, dynamic> json) =>
      _$NonGoalsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NonGoalsToJson(this);
}
