import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'decision.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Decision extends Memory {
  const Decision({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Decision.fromJson(Map<String, dynamic> json) =>
      _$DecisionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DecisionToJson(this);
}
