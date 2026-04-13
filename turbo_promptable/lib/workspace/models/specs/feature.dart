import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/of_projects.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'feature.g.dart';

/// A user-facing feature scoped to one or more projects.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Feature extends Spec implements OfProjects {
  const Feature({
    required super.name,
    super.metaData,
    super.config,
    required this.projectIds,
  });

  @override
  final List<String> projectIds;

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}
