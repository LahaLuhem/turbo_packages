import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'concept.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
  createFactory: false,
  createToJson: false,
)
abstract class Concept extends Context {
  Concept({
    required super.name,
    super.metaData,
    super.config,
  });
}
