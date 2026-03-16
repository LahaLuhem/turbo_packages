import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/relationships/enums/relationship_type.dart';
import 'package:turbo_promptable/shared/converters/timestamp_or_date_time_converter.dart';
import 'package:turbo_promptable/shared/globals/g_now.dart';
import 'package:turbo_promptable/shared/models/auth_vars.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

part 'relationship_dto.g.dart';

@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  genericArgumentFactories: true,
)
class RelationshipDto<SOURCE_TYPE, TARGET_TYPE> extends TWriteableId {
  RelationshipDto({
    required this.id,
    required this.userId,
    required this.sourceId,
    required this.sourceType,
    required this.targetId,
    required this.targetType,
    required this.type,
    required this.bidirectional,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String id;
  final String userId;
  final String sourceId;
  final SOURCE_TYPE sourceType;
  final String targetId;
  final TARGET_TYPE targetType;
  @JsonKey(fromJson: _relationshipTypeFromJson, toJson: _relationshipTypeToJson)
  final RelationshipType type;
  final bool bidirectional;
  @TimestampOrDateTimeConverter()
  final DateTime createdAt;
  @TimestampOrDateTimeConverter()
  final DateTime updatedAt;

  static RelationshipDto<S, T> create<S, T>({
    required AuthVars vars,
    required String sourceId,
    required S sourceType,
    required String targetId,
    required T targetType,
    required RelationshipType type,
    required bool bidirectional,
  }) {
    return RelationshipDto<S, T>(
      id: vars.id,
      userId: vars.userId,
      sourceId: sourceId,
      sourceType: sourceType,
      targetId: targetId,
      targetType: targetType,
      type: type,
      bidirectional: bidirectional,
      createdAt: vars.now,
      updatedAt: vars.now,
    );
  }

  factory RelationshipDto.fromJson(
    Map<String, dynamic> json,
    SOURCE_TYPE Function(Object? json) fromJsonSourceType,
    TARGET_TYPE Function(Object? json) fromJsonTargetType,
  ) => _$RelationshipDtoFromJson(json, fromJsonSourceType, fromJsonTargetType);

  @override
  Map<String, dynamic> toJson() => throw UnimplementedError(
    'Use toJsonWithConverters instead for generic types',
  );

  Map<String, dynamic> toJsonWithConverters(
    Object? Function(SOURCE_TYPE value) toJsonSourceType,
    Object? Function(TARGET_TYPE value) toJsonTargetType,
  ) => _$RelationshipDtoToJson(this, toJsonSourceType, toJsonTargetType);

  RelationshipDto<SOURCE_TYPE, TARGET_TYPE> copyWith({
    RelationshipType? type,
    bool? bidirectional,
  }) => RelationshipDto<SOURCE_TYPE, TARGET_TYPE>(
    id: id,
    userId: userId,
    sourceId: sourceId,
    sourceType: sourceType,
    targetId: targetId,
    targetType: targetType,
    type: type ?? this.type,
    bidirectional: bidirectional ?? this.bidirectional,
    createdAt: createdAt,
    updatedAt: gNow,
  );
}

RelationshipType _relationshipTypeFromJson(String value) =>
    RelationshipType.fromJson(value);

String _relationshipTypeToJson(RelationshipType value) => value.toJson();

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UpdateRelationshipDtoRequest extends TWriteableId {
  UpdateRelationshipDtoRequest({
    this.type,
    this.bidirectional,
  });

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get id => '';

  @JsonKey(
    fromJson: _nullableRelationshipTypeFromJson,
    toJson: _nullableRelationshipTypeToJson,
  )
  final RelationshipType? type;
  final bool? bidirectional;
  @JsonKey(includeToJson: true)
  @TimestampOrDateTimeConverter()
  DateTime get updatedAt => gNow;

  static const fromJsonFactory = _$UpdateRelationshipDtoRequestFromJson;
  factory UpdateRelationshipDtoRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRelationshipDtoRequestFromJson(json);
  static const toJsonFactory = _$UpdateRelationshipDtoRequestToJson;
  @override
  Map<String, dynamic> toJson() {
    final map = _$UpdateRelationshipDtoRequestToJson(this);
    map['updatedAt'] = const TimestampOrDateTimeConverter().toJson(updatedAt);
    return map;
  }
}

RelationshipType? _nullableRelationshipTypeFromJson(String? value) =>
    value == null ? null : RelationshipType.fromJson(value);

String? _nullableRelationshipTypeToJson(RelationshipType? value) =>
    value?.toJson();
