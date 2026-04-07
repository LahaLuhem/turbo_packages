import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'insight.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Insight extends Memory {
  Insight({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Insight Function(Map<String, dynamic> json) fromJsonFactory =
      _$InsightFromJson;
  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
  static final Map<String, dynamic> Function(Insight value) toJsonFactory =
      _$InsightToJson;
  @override
  Map<String, dynamic> toJson() => _$InsightToJson(this);
}
