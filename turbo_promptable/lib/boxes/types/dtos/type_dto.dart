import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/boxes/types/dtos/type_condition_dto.dart';
import 'package:turbo_promptable/shared/abstracts/t_searchable.dart';
import 'package:turbo_promptable/shared/converters/timestamp_or_date_time_converter.dart';
import 'package:turbo_promptable/shared/extensions/string_extension.dart';
import 'package:turbo_promptable/shared/globals/g_now.dart';
import 'package:turbo_promptable/shared/models/auth_vars.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

part 'type_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TypeDto extends TWriteableId implements TSearchable {
  TypeDto({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.emoji,
    required this.conditions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TypeDto.create({
    required AuthVars vars,
    required String name,
    String? description,
    required String emoji,
    required List<TypeConditionDto> conditions,
  }) {
    return TypeDto(
      id: vars.id,
      userId: vars.userId,
      name: name,
      description: description,
      emoji: emoji,
      conditions: conditions,
      createdAt: vars.now,
      updatedAt: vars.now,
    );
  }

  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String id;
  final String userId;
  final String name;
  final String? description;
  @JsonKey(defaultValue: '\u{1F4CB}')
  final String emoji;
  final List<TypeConditionDto> conditions;
  @TimestampOrDateTimeConverter()
  final DateTime createdAt;
  @TimestampOrDateTimeConverter()
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toJson() => _$TypeDtoToJson(this);
  factory TypeDto.fromJson(Map<String, dynamic> json) =>
      _$TypeDtoFromJson(json);
  static const fromJsonFactory = _$TypeDtoFromJson;
  static const toJsonFactory = _$TypeDtoToJson;

  TypeDto copyWith({
    String? name,
    String? description,
    String? emoji,
    List<TypeConditionDto>? conditions,
  }) => TypeDto(
    id: id,
    userId: userId,
    name: name ?? this.name,
    description: description ?? this.description,
    emoji: emoji ?? this.emoji,
    conditions: conditions ?? this.conditions,
    createdAt: createdAt,
    updatedAt: gNow,
  );

  @override
  bool isSearchMatch(String normalizedSearchTerm) {
    final pName = name.normalized;
    if (pName.contains(normalizedSearchTerm)) return true;
    if (description != null && description!.isNotEmpty) {
      final pDesc = description!.normalized;
      if (pDesc.contains(normalizedSearchTerm)) return true;
    }
    return false;
  }
}

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UpdateTypeDtoRequest extends TWriteableId {
  UpdateTypeDtoRequest({
    this.name,
    this.description,
    this.emoji,
    this.conditions,
  });

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get id => '';

  final String? name;
  final String? description;
  final String? emoji;
  final List<TypeConditionDto>? conditions;
  @JsonKey(includeToJson: true)
  @TimestampOrDateTimeConverter()
  DateTime get updatedAt => gNow;

  static const fromJsonFactory = _$UpdateTypeDtoRequestFromJson;
  factory UpdateTypeDtoRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTypeDtoRequestFromJson(json);
  static const toJsonFactory = _$UpdateTypeDtoRequestToJson;
  @override
  Map<String, dynamic> toJson() {
    final map = _$UpdateTypeDtoRequestToJson(this);
    map['updatedAt'] = const TimestampOrDateTimeConverter().toJson(updatedAt);
    return map;
  }
}
