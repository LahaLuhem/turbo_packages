import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/specs/requirement.dart';

part 'fr.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TFR extends TRequirement {
  TFR({
    required super.name,
    super.metaData,
    super.config,
  });

  factory TFR.fromJson(Map<String, dynamic> json) => _$TFRFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TFRToJson(this);
}
