import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'issue.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Issue extends TPromptable {
  Issue({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$IssueToJson(this);
}
