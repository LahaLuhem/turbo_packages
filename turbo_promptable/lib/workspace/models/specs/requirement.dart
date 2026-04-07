import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

export 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'requirement.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TRequirement extends Spec {
  TRequirement({
    required super.name,
    super.metaData,
    super.config,
  });

  factory TRequirement.fromJson(Map<String, dynamic> json) =>
      _$TRequirementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TRequirementToJson(this);
}
