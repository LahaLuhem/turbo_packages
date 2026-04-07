import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'decision.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Decision extends Memory {
  Decision({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Decision Function(Map<String, dynamic> json) fromJsonFactory =
      _$DecisionFromJson;
  factory Decision.fromJson(Map<String, dynamic> json) =>
      _$DecisionFromJson(json);
  static final Map<String, dynamic> Function(Decision value) toJsonFactory =
      _$DecisionToJson;
  @override
  Map<String, dynamic> toJson() => _$DecisionToJson(this);
}
