import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'spec.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Spec extends TPromptable {
  const Spec({
    required super.name,
    super.metaData,
  });

  factory Spec.fromJson(Map<String, dynamic> json) => _$SpecFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SpecToJson(this);
}
