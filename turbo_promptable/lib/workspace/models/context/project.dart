import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'project.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Project extends Context {
  const Project({
    required super.name,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
