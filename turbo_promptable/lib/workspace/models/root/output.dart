import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

part 'output.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Output extends TPromptable {
  const Output({
    required super.name,
    super.metaData,
    this.criteria,
    this.constraints,
    required this.schema,
  });

  final Checklist? criteria;
  final Checklist? constraints;
  final String schema;

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$OutputToJson(this);
}
