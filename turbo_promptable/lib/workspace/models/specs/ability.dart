import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/of_features.dart';
import 'package:turbo_promptable/workspace/abstracts/of_modules.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'ability.g.dart';

/// A discrete capability that a system provides, linked to features and modules.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Ability extends Spec implements OfFeatures, OfModules {
  /// Creates an ability scoped to the given [featureIds] and [moduleIds].
  const Ability({
    required super.name,
    super.metaData,
    required this.featureIds,
    required this.moduleIds,
  });

  /// Feature identifiers linked to this ability.
  @override
  final List<String> featureIds;

  /// Module identifiers linked to this ability.
  @override
  final List<String> moduleIds;

  /// Deserializes an [Ability] from [json].
  factory Ability.fromJson(Map<String, dynamic> json) =>
      _$AbilityFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AbilityToJson(this);
}
