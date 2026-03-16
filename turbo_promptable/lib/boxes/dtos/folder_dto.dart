import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/t_searchable.dart';
import 'package:turbo_promptable/shared/converters/timestamp_or_date_time_converter.dart';
import 'package:turbo_promptable/shared/extensions/string_extension.dart';
import 'package:turbo_promptable/shared/globals/g_now.dart';
import 'package:turbo_promptable/shared/models/auth_vars.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

part 'folder_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class FolderDto extends TWriteableId implements TSearchable {
  FolderDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.path,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FolderDto.create({
    required AuthVars vars,
    required String name,
    required String emoji,
    required String path,
    bool isActive = false,
  }) {
    return FolderDto(
      id: vars.id,
      userId: vars.userId,
      name: name,
      emoji: emoji,
      path: path,
      isActive: isActive,
      createdAt: vars.now,
      updatedAt: vars.now,
    );
  }

  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String id;
  final String userId;
  final String name;
  @JsonKey(defaultValue: '\u{1F4C1}')
  final String emoji;
  final String path;
  final bool isActive;
  @TimestampOrDateTimeConverter()
  final DateTime createdAt;
  @TimestampOrDateTimeConverter()
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toJson() => _$FolderDtoToJson(this);
  factory FolderDto.fromJson(Map<String, dynamic> json) =>
      _$FolderDtoFromJson(json);
  static const fromJsonFactory = _$FolderDtoFromJson;
  static const toJsonFactory = _$FolderDtoToJson;

  FolderDto copyWith({
    String? name,
    String? emoji,
    String? path,
    bool? isActive,
  }) => FolderDto(
    id: id,
    userId: userId,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    path: path ?? this.path,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: gNow,
  );

  @override
  bool isSearchMatch(String normalizedSearchTerm) {
    final pName = name.normalized;
    final pPath = path.normalized;
    return pName.contains(normalizedSearchTerm) ||
        pPath.contains(normalizedSearchTerm);
  }
}

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UpdateFolderDtoRequest extends TWriteableId {
  UpdateFolderDtoRequest({
    this.name,
    this.emoji,
    this.path,
    this.isActive,
  });

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get id => '';

  final String? name;
  final String? emoji;
  final String? path;
  final bool? isActive;
  @JsonKey(includeToJson: true)
  @TimestampOrDateTimeConverter()
  DateTime get updatedAt => gNow;

  static const fromJsonFactory = _$UpdateFolderDtoRequestFromJson;
  factory UpdateFolderDtoRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateFolderDtoRequestFromJson(json);
  static const toJsonFactory = _$UpdateFolderDtoRequestToJson;
  @override
  Map<String, dynamic> toJson() {
    final map = _$UpdateFolderDtoRequestToJson(this);
    map['updatedAt'] = const TimestampOrDateTimeConverter().toJson(updatedAt);
    return map;
  }

  UpdateFolderDtoRequest copyWith({
    String? name,
    String? emoji,
    String? path,
    bool? isActive,
  }) => UpdateFolderDtoRequest(
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    path: path ?? this.path,
    isActive: isActive ?? this.isActive,
  );
}
