import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/of_features.dart';
import 'package:turbo_promptable/workspace/abstracts/of_modules.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'ability.g.dart';

/// A discrete capability that a system provides, linked to features and modules.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Ability extends Spec implements OfFeatures, OfModules {
  const Ability({
    required super.name,
    super.metaData,
    super.config,
    required this.featureIds,
    required this.moduleIds,
  });

  @override
  final List<String> featureIds;
  @override
  final List<String> moduleIds;

  factory Ability.fromJson(Map<String, dynamic> json) =>
      _$AbilityFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AbilityToJson(this);
}
