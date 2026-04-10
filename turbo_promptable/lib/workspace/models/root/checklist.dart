import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'checklist.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Checklist extends TPromptable {
  const Checklist({
    required super.name,
    super.config,
    super.metaData,
    required this.items,
  });

  final List<String> items;

  factory Checklist.fromJson(Map<String, dynamic> json) =>
      _$ChecklistFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ChecklistToJson(this);
}
