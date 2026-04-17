import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'acceptance_criteria.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class AcceptanceCriteria extends Checklist {
  const AcceptanceCriteria(List<String> items)
    : super(
        name: 'Acceptance Criteria',
        items: items,
      );

  factory AcceptanceCriteria.fromJson(Map<String, dynamic> json) =>
      _$AcceptanceCriteriaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AcceptanceCriteriaToJson(this);
}
