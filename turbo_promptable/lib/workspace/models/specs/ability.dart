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

  static final Ability Function(Map<String, dynamic> json) fromJsonFactory =
      _$AbilityFromJson;
  factory Ability.fromJson(Map<String, dynamic> json) => _$AbilityFromJson(json);
  static final Map<String, dynamic> Function(Ability value) toJsonFactory =
      _$AbilityToJson;
  @override
  Map<String, dynamic> toJson() => _$AbilityToJson(this);
}
