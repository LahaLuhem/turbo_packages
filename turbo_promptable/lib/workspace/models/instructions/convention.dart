import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';

part 'convention.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Convention extends Instruction {
  Convention({
    required super.name,
    super.metaData,
    super.config,
    super.principles,
    super.rules,
    super.reasons,
    super.mindset,
    super.approach,
    super.responsibilities,
    super.understandings,
    super.examples,
  });

  factory Convention.fromJson(Map<String, dynamic> json) =>
      _$ConventionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ConventionToJson(this);
}
