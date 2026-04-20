// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Persona _$PersonaFromJson(Map<String, dynamic> json) => Persona(
  name: json['name'] as String,
  expertise: json['expertise'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  instructions: (json['instructions'] as List<dynamic>?)
      ?.map((e) => Instruction.fromJson(e as Map<String, dynamic>))
      .toList(),
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
      .toList(),
  identity: json['identity'] as String?,
);

Map<String, dynamic> _$PersonaToJson(Persona instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'instructions': ?instance.instructions?.map((e) => e.toJson()).toList(),
  'tools': ?instance.tools?.map((e) => e.toJson()).toList(),
  'expertise': instance.expertise,
  'identity': ?instance.identity,
};
