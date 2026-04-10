import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'feature.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Feature extends Spec {
  const Feature({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}
