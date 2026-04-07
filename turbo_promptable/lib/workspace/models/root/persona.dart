import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/role.dart';

part 'persona.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
class Persona extends Role {
  Persona({
    required super.name,
    super.metaData,
    super.config,
    required super.expertise,
    super.activities,
    super.checklists,
    super.instructions,
    super.templates,
    super.tools,
    super.workflows,
    required this.identity,
  });

  final String identity;

  static final Persona Function(Map<String, dynamic> json) fromJsonFactory =
      _$PersonaFromJson;
  factory Persona.fromJson(Map<String, dynamic> json) => _$PersonaFromJson(json);
  static final Map<String, dynamic> Function(Persona value) toJsonFactory =
      _$PersonaToJson;
  @override
  Map<String, dynamic> toJson() => _$PersonaToJson(this);
}
