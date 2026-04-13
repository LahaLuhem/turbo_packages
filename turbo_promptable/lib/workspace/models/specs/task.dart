import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/of_issues.dart';
import 'package:turbo_promptable/workspace/abstracts/of_mockups.dart';
import 'package:turbo_promptable/workspace/abstracts/of_prds.dart';
import 'package:turbo_promptable/workspace/abstracts/of_prototypes.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'task.g.dart';

/// A unit of work derived from issues, PRDs, mockups, and prototypes.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Task extends Spec implements OfIssues, OfPrds, OfMockups, OfPrototypes {
  const Task({
    required super.name,
    super.metaData,
    super.config,
    this.issueIds,
    this.prdIds,
    this.mockupIds,
    this.prototypeIds,
  });

  @override
  final List<String>? issueIds;
  @override
  final List<String>? prdIds;
  @override
  final List<String>? mockupIds;
  @override
  final List<String>? prototypeIds;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
