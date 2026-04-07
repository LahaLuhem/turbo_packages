import 'package:turbo_promptable/workspace/abstracts/root/instruction.dart';

abstract class Convention extends Instruction {
  Convention({
    required super.name,
    super.metaData,
    super.config,
  });
}
