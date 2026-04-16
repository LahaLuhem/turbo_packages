import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'acceptance_criteria.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class AcceptanceCriteria extends Checklist {
  const AcceptanceCriteria({
    required super.name,
    required super.items,
  });

  factory AcceptanceCriteria.fromJson(Map<String, dynamic> json) =>
      _$AcceptanceCriteriaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AcceptanceCriteriaToJson(this);
}
