import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';
import 'package:turbo_promptable/workspace/models/root/goal.dart';
import 'package:turbo_promptable/workspace/models/root/issue.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'input.g.dart';

/// The request side of a [Step] or [Activity]: a prose [request] describing
/// exactly what the step receives, plus optional structured context.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Input extends TPromptable {
  const Input({
    required super.name,
    super.metaData,
    this.context,
    this.goals,
    this.issues,
    this.specs,
  });

  final List<Context>? context;
  final List<Goal>? goals;
  final List<Issue>? issues;
  final List<Spec>? specs;

  factory Input.fromJson(Map<String, dynamic> json) => _$InputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$InputToJson(this);
}
