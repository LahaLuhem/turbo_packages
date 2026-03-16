import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/actors/dtos/role_dto.dart';
import 'package:turbo_promptable/boxes/dtos/area_dto.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'team_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TeamDto extends TurboPromptable {
  TeamDto({
    this.areas,
    this.roles,
  });

  final List<AreaDto>? areas;
  final List<RoleDto>? roles;

  static const fromJsonFactory = _$TeamDtoFromJson;
  factory TeamDto.fromJson(Map<String, dynamic> json) =>
      _$TeamDtoFromJson(json);
  static const toJsonFactory = _$TeamDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$TeamDtoToJson(this);

  TeamDto copyWith({
    List<AreaDto>? areas,
    List<RoleDto>? roles,
  }) {
    return TeamDto(
      areas: areas ?? this.areas,
      roles: roles ?? this.roles,
    );
  }

  @override
  String toString() => 'TeamDto{areas: $areas, roles: $roles}';
}
