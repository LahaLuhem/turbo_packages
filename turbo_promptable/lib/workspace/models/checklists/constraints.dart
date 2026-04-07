import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'constraints.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
abstract class Constraints extends Checklist {
  Constraints({
    required super.name,
    required super.items,
    super.config,
  });
}
