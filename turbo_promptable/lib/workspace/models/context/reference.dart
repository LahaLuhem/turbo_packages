import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'reference.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Reference extends TPromptable {
  const Reference({
    required super.name,
    super.metaData,
  });

  factory Reference.fromJson(Map<String, dynamic> json) =>
      _$ReferenceFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ReferenceToJson(this);
}
