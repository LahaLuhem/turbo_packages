import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/of_abilities.dart';
import 'package:turbo_promptable/workspace/abstracts/of_features.dart';
import 'package:turbo_promptable/workspace/abstracts/of_issues.dart';
import 'package:turbo_promptable/workspace/abstracts/of_journeys.dart';
import 'package:turbo_promptable/workspace/abstracts/of_mockups.dart';
import 'package:turbo_promptable/workspace/abstracts/of_modules.dart';
import 'package:turbo_promptable/workspace/abstracts/of_prds.dart';
import 'package:turbo_promptable/workspace/abstracts/of_scenarios.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'prototype.g.dart';

/// An interactive prototype linked to features, modules, abilities, journeys, scenarios, issues, PRDs, and mockups.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Prototype extends Spec
    implements
        OfAbilities,
        OfFeatures,
        OfModules,
        OfJourneys,
        OfScenarios,
        OfIssues,
        OfPrds,
        OfMockups {
  const Prototype({
    required super.name,
    super.metaData,
    super.config,
    this.featureIds,
    this.moduleIds,
    this.abilityIds,
    this.journeyIds,
    this.scenarioIds,
    this.issueIds,
    this.prdIds,
    this.mockupIds,
  });

  @override
  final List<String>? featureIds;
  @override
  final List<String>? moduleIds;
  @override
  final List<String>? abilityIds;
  @override
  final List<String>? journeyIds;
  @override
  final List<String>? scenarioIds;
  @override
  final List<String>? issueIds;
  @override
  final List<String>? prdIds;
  @override
  final List<String>? mockupIds;

  factory Prototype.fromJson(Map<String, dynamic> json) =>
      _$PrototypeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PrototypeToJson(this);
}
