import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/of_abilities.dart';
import 'package:turbo_promptable/workspace/abstracts/of_features.dart';
import 'package:turbo_promptable/workspace/abstracts/of_issues.dart';
import 'package:turbo_promptable/workspace/abstracts/of_journeys.dart';
import 'package:turbo_promptable/workspace/abstracts/of_modules.dart';
import 'package:turbo_promptable/workspace/abstracts/of_prds.dart';
import 'package:turbo_promptable/workspace/abstracts/of_scenarios.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'mockup.g.dart';

/// A visual mockup linked to abilities, features, modules, journeys, scenarios, issues, and PRDs.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Mockup extends Spec
    implements
        OfAbilities,
        OfFeatures,
        OfModules,
        OfJourneys,
        OfScenarios,
        OfIssues,
        OfPrds {
  const Mockup({
    required super.name,
    super.metaData,
    super.config,
    this.abilityIds,
    this.featureIds,
    this.moduleIds,
    this.journeyIds,
    this.scenarioIds,
    this.issueIds,
    this.prdIds,
  });

  @override
  final List<String>? abilityIds;
  @override
  final List<String>? featureIds;
  @override
  final List<String>? moduleIds;
  @override
  final List<String>? journeyIds;
  @override
  final List<String>? scenarioIds;
  @override
  final List<String>? issueIds;
  @override
  final List<String>? prdIds;

  factory Mockup.fromJson(Map<String, dynamic> json) => _$MockupFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MockupToJson(this);
}
