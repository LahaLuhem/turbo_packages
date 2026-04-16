import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'actor.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Actor extends Context {
  const Actor({
    required super.name,
    super.metaData,
  });

  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ActorToJson(this);
}
