import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'insight.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
  createFactory: false,
  createToJson: false,
)
abstract class Insight extends Memory {
  Insight({
    required super.name,
    super.metaData,
    super.config,
  });
}
