import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'instruction.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Instruction extends TPromptable {
  Instruction({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) =>
      _$InstructionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$InstructionToJson(this);
}
