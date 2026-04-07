import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';

part 'skill.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Skill extends Instruction {
  Skill({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Skill Function(Map<String, dynamic> json) fromJsonFactory =
      _$SkillFromJson;
  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);
  static final Map<String, dynamic> Function(Skill value) toJsonFactory =
      _$SkillToJson;
  @override
  Map<String, dynamic> toJson() => _$SkillToJson(this);
}
