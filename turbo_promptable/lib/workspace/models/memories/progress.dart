import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'progress.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Progress extends Memory {
  Progress({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Progress Function(Map<String, dynamic> json) fromJsonFactory =
      _$ProgressFromJson;
  factory Progress.fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);
  static final Map<String, dynamic> Function(Progress value) toJsonFactory =
      _$ProgressToJson;
  @override
  Map<String, dynamic> toJson() => _$ProgressToJson(this);
}
