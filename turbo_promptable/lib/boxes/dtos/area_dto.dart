import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/actors/dtos/role_dto.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'area_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class AreaDto extends TurboPromptable {
  AreaDto({
    this.roles,
  });

  final List<RoleDto>? roles;

  static const fromJsonFactory = _$AreaDtoFromJson;
  factory AreaDto.fromJson(Map<String, dynamic> json) =>
      _$AreaDtoFromJson(json);
  static const toJsonFactory = _$AreaDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$AreaDtoToJson(this);

  @override
  String toString() => 'AreaDto{roles: $roles}';

  AreaDto copyWith({
    List<RoleDto>? roles,
  }) => AreaDto(
    roles: roles ?? this.roles,
  );
}
