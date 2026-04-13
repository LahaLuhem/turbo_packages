import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/of_abilities.dart';
import 'package:turbo_promptable/workspace/abstracts/of_journeys.dart';
import 'package:turbo_promptable/workspace/abstracts/of_scenarios.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

export 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'requirement.g.dart';

/// Base class for requirements that reference abilities, journeys, and scenarios.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Requirement extends Spec implements OfAbilities, OfJourneys, OfScenarios {
  const Requirement({
    required super.name,
    super.metaData,
    super.config,
    required this.abilityIds,
    required this.journeyIds,
    required this.scenarioIds,
  });

  @override
  final List<String>? abilityIds;
  @override
  final List<String>? journeyIds;
  @override
  final List<String>? scenarioIds;

  factory Requirement.fromJson(Map<String, dynamic> json) =>
      _$RequirementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RequirementToJson(this);
}
