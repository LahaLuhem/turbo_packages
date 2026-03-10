import 'package:json_annotation/json_annotation.dart';

part 'file_entry_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class FileEntryDto {
  final String path;
  final String? content;
  final int? lastModified;

  const FileEntryDto({
    required this.path,
    required this.content,
    required this.lastModified,
  });

  static const fromJsonFactory = _$FileEntryDtoFromJson;
  factory FileEntryDto.fromJson(Map<String, dynamic> json) =>
      _$FileEntryDtoFromJson(json);
  static const toJsonFactory = _$FileEntryDtoToJson;
  Map<String, dynamic> toJson() => _$FileEntryDtoToJson(this);

  FileEntryDto copyWith({
    String? path,
    String? content,
    int? lastModified,
  }) {
    return FileEntryDto(
      path: path ?? this.path,
      content: content ?? this.content,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  String toString() {
    return 'FileEntryDto{path: $path, content: $content, lastModified: $lastModified}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileEntryDto &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          content == other.content &&
          lastModified == other.lastModified;

  @override
  int get hashCode => path.hashCode ^ content.hashCode ^ lastModified.hashCode;
}
