import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

part 'role.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Role extends TPromptable {
  const Role({
    required super.name,
    super.metaData,
    required this.expertise,
    this.instructions,
    this.tools,
  });

  final List<Instruction>? instructions;
  final List<Tool>? tools;
  final String expertise;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RoleToJson(this);

  Role copyWith({
    String? name,
    TMetaData? metaData,
    String? expertise,
    List<Instruction>? instructions,
    List<Tool>? tools,
  }) => Role(
    name: name ?? this.name,
    metaData: metaData ?? this.metaData,
    expertise: expertise ?? this.expertise,
    instructions: instructions ?? this.instructions,
    tools: tools ?? this.tools,
  );
}
