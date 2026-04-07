import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/root/input.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';
import 'package:turbo_promptable/workspace/models/root/output.dart';

part 'step.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Step extends TPromptable {
  Step({
    required super.name,
    super.metaData,
    super.config,
    required this.input,
    required this.instructions,
    required this.output,
  });

  final Input input;
  final List<Instruction>? instructions;
  final Output output;

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StepToJson(this);
}
