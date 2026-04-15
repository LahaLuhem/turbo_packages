import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'instruction.g.dart';

/// Behavioural guidance containing [principles], [rules], [mindset], and [examples].
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Instruction extends TPromptable {
  const Instruction({
    required super.name,
    super.metaData,
    super.config,
    this.principles,
    this.rules,
    this.reasons,
    this.mindset,
    this.approach,
    this.responsibilities,
    this.understandings,
    this.examples,
  });

  final List<String>? principles;
  final List<String>? rules;
  final List<String>? reasons;
  final List<String>? mindset;
  final List<String>? approach;
  final List<String>? responsibilities;
  final List<String>? understandings;
  final List<String>? examples;

  factory Instruction.fromJson(Map<String, dynamic> json) =>
      _$InstructionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$InstructionToJson(this);
}
