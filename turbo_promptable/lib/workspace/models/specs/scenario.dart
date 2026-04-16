import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/of_abilities.dart';
import 'package:turbo_promptable/workspace/abstracts/of_journeys.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'scenario.g.dart';

/// A usage scenario that exercises one or more abilities within a journey.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TScenario extends Spec implements OfAbilities, OfJourneys {
  const TScenario({
    required super.name,
    super.metaData,
    this.abilityIds,
    this.journeyIds,
  });

  @override
  final List<String>? abilityIds;

  @override
  final List<String>? journeyIds;

  factory TScenario.fromJson(Map<String, dynamic> json) =>
      _$TScenarioFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TScenarioToJson(this);
}
