import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

@JsonSerializable(
  createFactory: false,
  createToJson: false,
)
/// Base class for promptable models that can be spawned as CLI processes.
abstract class TSpawnable extends TPromptable {
  const TSpawnable({
    required super.name,
    required this.command,
    super.description,
    super.metaData,
    super.cascadeNameToMetaData = true,
    super.cascadeDescriptionToMetaData = true,
    super.values,
    super.value,
  });

  final String command;
}
