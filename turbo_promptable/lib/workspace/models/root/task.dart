import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'task.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TTask extends TPromptable {
  TTask({
    required super.name,
    super.metaData,
    super.config,
  });

  factory TTask.fromJson(Map<String, dynamic> json) => _$TTaskFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TTaskToJson(this);
}
