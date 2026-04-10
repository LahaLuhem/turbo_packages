import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'scenario.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TScenario extends Spec {
  const TScenario({
    required super.name,
    super.metaData,
    super.config,
  });

  factory TScenario.fromJson(Map<String, dynamic> json) =>
      _$TScenarioFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TScenarioToJson(this);
}
