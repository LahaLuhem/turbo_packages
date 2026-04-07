import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'actor.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Actor extends Context {
  Actor({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Actor Function(Map<String, dynamic> json) fromJsonFactory =
      _$ActorFromJson;
  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);
  static final Map<String, dynamic> Function(Actor value) toJsonFactory =
      _$ActorToJson;
  @override
  Map<String, dynamic> toJson() => _$ActorToJson(this);
}
