import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'instruction_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class InstructionDto extends TurboPromptable {
  InstructionDto();

  static const fromJsonFactory = _$InstructionDtoFromJson;
  factory InstructionDto.fromJson(Map<String, dynamic> json) =>
      _$InstructionDtoFromJson(json);
  static const toJsonFactory = _$InstructionDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$InstructionDtoToJson(this);

  @override
  String toString() => 'InstructionDto()';
}
