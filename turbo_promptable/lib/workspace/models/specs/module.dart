import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/of_projects.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'module.g.dart';

/// A logical module that groups related functionality within a project.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Module extends Spec implements OfProjects {
  const Module({
    required super.name,
    super.metaData,
    required this.projectIds,
  });

  @override
  final List<String> projectIds;

  factory Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ModuleToJson(this);
}
