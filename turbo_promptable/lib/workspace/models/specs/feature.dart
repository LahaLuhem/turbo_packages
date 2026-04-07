import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'feature.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Feature extends Spec {
  Feature({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Feature Function(Map<String, dynamic> json) fromJsonFactory =
      _$FeatureFromJson;
  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);
  static final Map<String, dynamic> Function(Feature value) toJsonFactory =
      _$FeatureToJson;
  @override
  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}
