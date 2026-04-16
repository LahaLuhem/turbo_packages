import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'constraints.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Constraints extends Checklist {
  const Constraints({
    required super.name,
    required super.items,
  });

  factory Constraints.fromJson(Map<String, dynamic> json) =>
      _$ConstraintsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ConstraintsToJson(this);
}
