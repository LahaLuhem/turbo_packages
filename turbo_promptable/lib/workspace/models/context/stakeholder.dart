import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'stakeholder.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Stakeholder extends Context {
  const Stakeholder({
    required super.name,
  });

  factory Stakeholder.fromJson(Map<String, dynamic> json) =>
      _$StakeholderFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StakeholderToJson(this);
}
