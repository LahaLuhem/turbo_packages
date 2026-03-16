import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/actors/dtos/persona_dto.dart';
import 'package:turbo_promptable/actors/dtos/role_dto.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'person_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class PersonDto extends TurboPromptable {
  PersonDto({this.role, this.persona});

  final RoleDto? role;
  final PersonaDto? persona;

  static const fromJsonFactory = _$PersonDtoFromJson;
  factory PersonDto.fromJson(Map<String, dynamic> json) =>
      _$PersonDtoFromJson(json);
  static const toJsonFactory = _$PersonDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$PersonDtoToJson(this);

  PersonDto copyWith({
    RoleDto? role,
    PersonaDto? persona,
  }) => PersonDto(
    role: role ?? this.role,
    persona: persona ?? this.persona,
  );

  @override
  String toString() => 'PersonDto{role: $role, persona: $persona}';
}
