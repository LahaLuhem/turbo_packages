import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'progress.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Progress extends Memory {
  const Progress({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Progress.fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ProgressToJson(this);
}
