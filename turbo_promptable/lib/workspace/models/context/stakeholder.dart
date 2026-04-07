import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'stakeholder.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Stakeholder extends Context {
  Stakeholder({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Stakeholder Function(Map<String, dynamic> json) fromJsonFactory =
      _$StakeholderFromJson;
  factory Stakeholder.fromJson(Map<String, dynamic> json) =>
      _$StakeholderFromJson(json);
  static final Map<String, dynamic> Function(Stakeholder value) toJsonFactory =
      _$StakeholderToJson;
  @override
  Map<String, dynamic> toJson() => _$StakeholderToJson(this);
}
