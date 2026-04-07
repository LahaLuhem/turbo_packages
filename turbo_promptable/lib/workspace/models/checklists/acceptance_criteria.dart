import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'acceptance_criteria.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
abstract class AcceptanceCriteria extends Checklist {
  AcceptanceCriteria({
    required super.name,
    required super.items,
    super.config,
  });
}
