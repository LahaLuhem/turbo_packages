import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'acceptance_criteria.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class AcceptanceCriteria extends Checklist {
  AcceptanceCriteria({
    required super.name,
    required super.items,
    super.config,
  });

  static final AcceptanceCriteria Function(Map<String, dynamic> json)
      fromJsonFactory = _$AcceptanceCriteriaFromJson;
  factory AcceptanceCriteria.fromJson(Map<String, dynamic> json) =>
      _$AcceptanceCriteriaFromJson(json);
  static final Map<String, dynamic> Function(AcceptanceCriteria value)
      toJsonFactory = _$AcceptanceCriteriaToJson;
  @override
  Map<String, dynamic> toJson() => _$AcceptanceCriteriaToJson(this);
}
