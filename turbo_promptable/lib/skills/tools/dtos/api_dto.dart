import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'api_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class ApiDto extends TurboPromptable {
  ApiDto();

  static const fromJsonFactory = _$ApiDtoFromJson;
  factory ApiDto.fromJson(Map<String, dynamic> json) => _$ApiDtoFromJson(json);
  static const toJsonFactory = _$ApiDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$ApiDtoToJson(this);

  ApiDto copyWith() {
    return ApiDto();
  }

  @override
  String toString() => 'ApiDto()';
}
