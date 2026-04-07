import 'package:turbo_promptable/workspace/abstracts/root/instruction.dart';

abstract class Skill extends Instruction {
  Skill({
    required super.name,
    super.metaData,
    super.config,
  });
}
