import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'tool_dto.g.dart';

@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  genericArgumentFactories: true,
)
class ToolDto<INPUT, OUTPUT> extends TurboPromptable {
  ToolDto({
    this.input,
    this.output,
    this.instructions,
  });

  final INPUT? input;
  final OUTPUT? output;
  final String? instructions;

  List<TurboPromptable>? get children => null;

  factory ToolDto.fromJson(
    Map<String, dynamic> json,
    INPUT Function(Object? json) fromJsonINPUT,
    OUTPUT Function(Object? json) fromJsonOUTPUT,
  ) => _$ToolDtoFromJson(json, fromJsonINPUT, fromJsonOUTPUT);

  Map<String, dynamic> toJsonWithConverters(
    Object? Function(INPUT value) toJsonINPUT,
    Object? Function(OUTPUT value) toJsonOUTPUT,
  ) => _$ToolDtoToJson(this, toJsonINPUT, toJsonOUTPUT);

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError(
      'ToolDto.toJson() requires type converters. Use toJsonWithConverters() instead.',
    );
  }

  @override
  String toString() =>
      'ToolDto{input: $input, output: $output, instructions: $instructions}';
}
