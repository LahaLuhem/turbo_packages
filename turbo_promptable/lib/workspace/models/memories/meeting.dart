import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'meeting.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
  createFactory: false,
  createToJson: false,
)
abstract class Meeting extends Memory {
  Meeting({
    required super.name,
    super.metaData,
    super.config,
  });
}
