import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'ability.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Ability extends Spec {
  Ability({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Ability.fromJson(Map<String, dynamic> json) =>
      _$TAbilityFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TAbilityToJson(this);
}
