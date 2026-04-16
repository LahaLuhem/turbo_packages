import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'success_criteria.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class SuccessCriteria extends Checklist {
  const SuccessCriteria({
    required super.name,
    required super.items,
  });

  factory SuccessCriteria.fromJson(Map<String, dynamic> json) =>
      _$SuccessCriteriaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SuccessCriteriaToJson(this);
}
