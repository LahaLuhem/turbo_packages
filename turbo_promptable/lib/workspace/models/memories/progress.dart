import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'progress.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
  createFactory: false,
  createToJson: false,
)
abstract class Progress extends Memory {
  Progress({
    required super.name,
    super.metaData,
    super.config,
  });
}
