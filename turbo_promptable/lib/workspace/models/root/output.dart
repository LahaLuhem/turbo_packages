import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';

part 'output.g.dart';

/// The output side of an [Activity]: [fields], optional [template], and [checklists].
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Output extends TPromptable {
  const Output({
    required super.name,
    super.metaData,
    this.checklists,
    this.template,
  });

  final Template? template;
  final List<Checklist>? checklists;

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$OutputToJson(this);
}
