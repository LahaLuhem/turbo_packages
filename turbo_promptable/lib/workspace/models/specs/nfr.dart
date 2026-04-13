import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/specs/requirement.dart';

part 'nfr.g.dart';

/// A non-functional requirement linked to abilities, journeys, and scenarios.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TNFR extends Requirement {
  TNFR({
    required super.name,
    super.metaData,
    super.config,
    super.abilityIds,
    super.journeyIds,
    super.scenarioIds,
  });

  factory TNFR.fromJson(Map<String, dynamic> json) => _$TNFRFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TNFRToJson(this);
}
