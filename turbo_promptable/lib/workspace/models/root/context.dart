import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'context.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Context extends TPromptable {
  const Context({
    required super.name,
    super.metaData,
  });

  factory Context.fromJson(Map<String, dynamic> json) =>
      _$ContextFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ContextToJson(this);
}
