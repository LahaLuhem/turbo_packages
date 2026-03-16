import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/actors/dtos/expertise_dto.dart';
import 'package:turbo_promptable/actors/dtos/persona_dto.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'role_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class RoleDto extends TurboPromptable {
  RoleDto({
    required this.expertise,
    this.persona,
  });

  final PersonaDto? persona;
  final ExpertiseDto expertise;

  static const fromJsonFactory = _$RoleDtoFromJson;
  factory RoleDto.fromJson(Map<String, dynamic> json) =>
      _$RoleDtoFromJson(json);
  static const toJsonFactory = _$RoleDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$RoleDtoToJson(this);

  @override
  String toString() => 'RoleDto{persona: $persona, expertise: $expertise}';

  RoleDto copyWith({
    PersonaDto? persona,
    ExpertiseDto? expertise,
  }) => RoleDto(
    persona: persona ?? this.persona,
    expertise: expertise ?? this.expertise,
  );
}
