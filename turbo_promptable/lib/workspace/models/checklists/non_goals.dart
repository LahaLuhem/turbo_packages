import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'non_goals.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
abstract class NonGoals extends Checklist {
  NonGoals({
    required super.name,
    required super.items,
    super.config,
  });
}
