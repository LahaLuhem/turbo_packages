import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'concept.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Concept extends Context {
  const Concept({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Concept.fromJson(Map<String, dynamic> json) =>
      _$ConceptFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ConceptToJson(this);
}
