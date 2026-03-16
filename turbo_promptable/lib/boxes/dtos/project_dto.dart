import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/t_searchable.dart';
import 'package:turbo_promptable/shared/converters/timestamp_or_date_time_converter.dart';
import 'package:turbo_promptable/shared/extensions/string_extension.dart';
import 'package:turbo_promptable/shared/globals/g_now.dart';
import 'package:turbo_promptable/shared/models/auth_vars.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

part 'project_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class ProjectDto extends TWriteableId implements TSearchable {
  ProjectDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.emoji,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectDto.create({
    required AuthVars vars,
    required String name,
    required String emoji,
  }) {
    return ProjectDto(
      id: vars.id,
      userId: vars.userId,
      name: name,
      description: null,
      emoji: emoji,
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
  final String emoji;
  @TimestampOrDateTimeConverter()
  final DateTime createdAt;
  @TimestampOrDateTimeConverter()
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toJson() => _$ProjectDtoToJson(this);
  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);
  static const fromJsonFactory = _$ProjectDtoFromJson;
  static const toJsonFactory = _$ProjectDtoToJson;

  ProjectDto copyWith({
    String? name,
    String? description,
    bool clearDescription = false,
    String? emoji,
  }) => ProjectDto(
    id: id,
    userId: userId,
    name: name ?? this.name,
    description: clearDescription ? null : (description ?? this.description),
    emoji: emoji ?? this.emoji,
    createdAt: createdAt,
    updatedAt: gNow,
  );

  @override
  bool isSearchMatch(String normalizedSearchTerm) {
    final pName = name.normalized;
    final pDescription = description?.normalized;
    return pName.contains(normalizedSearchTerm) ||
        (pDescription != null && pDescription.contains(normalizedSearchTerm));
  }
}

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UpdateProjectDtoRequest extends TWriteableId {
  UpdateProjectDtoRequest({
    this.name,
    this.description,
    this.emoji,
  });

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get id => '';

  final String? name;
  final String? description;
  final String? emoji;
  @JsonKey(includeToJson: true)
  @TimestampOrDateTimeConverter()
  DateTime get updatedAt => gNow;

  static const fromJsonFactory = _$UpdateProjectDtoRequestFromJson;
  factory UpdateProjectDtoRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProjectDtoRequestFromJson(json);
  static const toJsonFactory = _$UpdateProjectDtoRequestToJson;
  @override
  Map<String, dynamic> toJson() {
    final map = _$UpdateProjectDtoRequestToJson(this);
    map['updatedAt'] = const TimestampOrDateTimeConverter().toJson(updatedAt);
    return map;
  }

  UpdateProjectDtoRequest copyWith({
    String? name,
    String? description,
    bool clearDescription = false,
    String? emoji,
  }) => UpdateProjectDtoRequest(
    name: name ?? this.name,
    description: clearDescription ? null : (description ?? this.description),
    emoji: emoji ?? this.emoji,
  );
}
