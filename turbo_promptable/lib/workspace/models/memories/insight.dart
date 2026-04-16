import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'insight.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Insight extends Memory {
  const Insight({
    required super.name,
    super.metaData,
  });

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$InsightToJson(this);
}
