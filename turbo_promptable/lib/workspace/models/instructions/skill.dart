import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';

part 'skill.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Skill extends Instruction {
  Skill({
    required super.name,
    super.metaData,
    super.principles,
    super.rules,
    super.reasons,
    super.mindset,
    super.approach,
    super.responsibilities,
    super.understandings,
    super.examples,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SkillToJson(this);
}
