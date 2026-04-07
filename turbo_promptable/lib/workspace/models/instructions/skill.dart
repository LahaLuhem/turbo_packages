import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';

part 'skill.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
  createFactory: false,
  createToJson: false,
)
abstract class Skill extends Instruction {
  Skill({
    required super.name,
    super.metaData,
    super.config,
  });
}
