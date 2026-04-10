import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';
import 'package:turbo_promptable/workspace/models/root/goal.dart';
import 'package:turbo_promptable/workspace/models/root/issue.dart';
import 'package:turbo_promptable/workspace/models/root/prompt_field.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'input.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Input extends TPromptable {
  const Input({
    required super.name,
    super.metaData,
    super.config,
    required this.request,
    required this.fields,
    this.context,
    this.goals,
    this.issues,
    this.checklists,
    this.specs,
  });

  final List<PromptField> fields;
  final List<Checklist>? checklists;
  final List<Context>? context;
  final List<Goal>? goals;
  final List<Issue>? issues;
  final List<Spec>? specs;
  final String request;

  factory Input.fromJson(Map<String, dynamic> json) => _$InputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$InputToJson(this);
}
