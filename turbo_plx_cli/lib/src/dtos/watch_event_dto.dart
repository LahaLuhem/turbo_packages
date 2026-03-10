import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_plx_cli/src/dtos/file_entry_dto.dart';
import 'package:turbo_plx_cli/src/enums/watch_event_type.dart';

part 'watch_event_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class WatchEventDto {
  final WatchEventType event;
  final String path;
  final String? content;
  final String? id;
  final int? lastModified;
  final List<FileEntryDto>? files;

  const WatchEventDto({
    required this.event,
    required this.path,
    this.content,
    this.id,
    this.lastModified,
    this.files,
  });

  static const fromJsonFactory = _$WatchEventDtoFromJson;
  factory WatchEventDto.fromJson(Map<String, dynamic> json) =>
      _$WatchEventDtoFromJson(json);
  static const toJsonFactory = _$WatchEventDtoToJson;
  Map<String, dynamic> toJson() => _$WatchEventDtoToJson(this);

  WatchEventDto copyWith({
    WatchEventType? event,
    String? path,
    String? content,
    String? id,
    int? lastModified,
    List<FileEntryDto>? files,
  }) {
    return WatchEventDto(
      event: event ?? this.event,
      path: path ?? this.path,
      content: content ?? this.content,
      id: id ?? this.id,
      lastModified: lastModified ?? this.lastModified,
      files: files ?? this.files,
    );
  }

  @override
  String toString() {
    return 'WatchEventDto{event: $event, path: $path, content: $content, id: $id, lastModified: $lastModified, files: $files}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchEventDto &&
          runtimeType == other.runtimeType &&
          event == other.event &&
          path == other.path &&
          content == other.content &&
          id == other.id &&
          lastModified == other.lastModified &&
          files == other.files;

  @override
  int get hashCode =>
      event.hashCode ^
      path.hashCode ^
      content.hashCode ^
      id.hashCode ^
      lastModified.hashCode ^
      files.hashCode;
}
