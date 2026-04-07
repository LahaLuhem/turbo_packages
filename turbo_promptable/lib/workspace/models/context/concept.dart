import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'concept.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Concept extends Context {
  Concept({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Concept Function(Map<String, dynamic> json) fromJsonFactory =
      _$ConceptFromJson;
  factory Concept.fromJson(Map<String, dynamic> json) =>
      _$ConceptFromJson(json);
  static final Map<String, dynamic> Function(Concept value) toJsonFactory =
      _$ConceptToJson;
  @override
  Map<String, dynamic> toJson() => _$ConceptToJson(this);
}
