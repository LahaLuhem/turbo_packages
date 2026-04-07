import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/specs/requirement.dart';

part 'nfr.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TNFR extends TRequirement {
  TNFR({
    required super.name,
    super.metaData,
    super.config,
  });

  factory TNFR.fromJson(Map<String, dynamic> json) => _$TNFRFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TNFRToJson(this);
}
