import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';

part 'convention.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
  createFactory: false,
  createToJson: false,
)
abstract class Convention extends Instruction {
  Convention({
    required super.name,
    super.metaData,
    super.config,
  });
}
