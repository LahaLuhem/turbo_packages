import 'package:json_annotation/json_annotation.dart';
import 'package:pew_pew_cli/src/constants/pew_pew_cli_defaults.dart';

part 'watch_config_dto.g.dart';

@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
class WatchConfigDto {
  const WatchConfigDto({
    this.throttleMs = PewPewCliDefaults.throttleMs,
    this.extensions = PewPewCliDefaults.extensions,
    this.ignoreFolders = PewPewCliDefaults.ignoreFolders,
  });

  final int throttleMs;
  final List<String> extensions;
  final List<String> ignoreFolders;

  static const fromJsonFactory = _$WatchConfigDtoFromJson;
  factory WatchConfigDto.fromJson(Map<String, dynamic> json) =>
      _$WatchConfigDtoFromJson(json);
  static const toJsonFactory = _$WatchConfigDtoToJson;
  Map<String, dynamic> toJson() => _$WatchConfigDtoToJson(this);

  WatchConfigDto copyWith({
    int? throttleMs,
    List<String>? extensions,
    List<String>? ignoreFolders,
  }) {
    return WatchConfigDto(
      throttleMs: throttleMs ?? this.throttleMs,
      extensions: extensions ?? this.extensions,
      ignoreFolders: ignoreFolders ?? this.ignoreFolders,
    );
  }

  @override
  String toString() {
    return 'WatchConfigDto{throttleMs: $throttleMs, extensions: $extensions, ignoreFolders: $ignoreFolders}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchConfigDto &&
          runtimeType == other.runtimeType &&
          throttleMs == other.throttleMs &&
          extensions == other.extensions &&
          ignoreFolders == other.ignoreFolders;

  @override
  int get hashCode =>
      throttleMs.hashCode ^ extensions.hashCode ^ ignoreFolders.hashCode;
}
