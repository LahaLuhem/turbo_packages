import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'reference_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class ReferenceDto extends TurboPromptable {
  ReferenceDto();

  static const fromJsonFactory = _$ReferenceDtoFromJson;
  factory ReferenceDto.fromJson(Map<String, dynamic> json) =>
      _$ReferenceDtoFromJson(json);
  static const toJsonFactory = _$ReferenceDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$ReferenceDtoToJson(this);

  ReferenceDto copyWith() {
    return ReferenceDto();
  }

  @override
  String toString() => 'ReferenceDto()';
}
