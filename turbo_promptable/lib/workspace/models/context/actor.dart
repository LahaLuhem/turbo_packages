import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'actor.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
abstract class Actor extends Context {
  Actor({
    required super.name,
    super.metaData,
    super.config,
  });
}
