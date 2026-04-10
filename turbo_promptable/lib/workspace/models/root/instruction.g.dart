// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instruction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Instruction _$InstructionFromJson(Map<String, dynamic> json) => Instruction(
  name: json['name'] as String,
  principles: (json['principles'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  rules: (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList(),
  reasons: (json['reasons'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  mindset: (json['mindset'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  approach: (json['approach'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  responsibilities: (json['responsibilities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  understandings: (json['understandings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  examples: (json['examples'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$InstructionToJson(Instruction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'principles': ?instance.principles,
      'rules': ?instance.rules,
      'reasons': ?instance.reasons,
      'mindset': ?instance.mindset,
      'approach': ?instance.approach,
      'responsibilities': ?instance.responsibilities,
      'understandings': ?instance.understandings,
      'examples': ?instance.examples,
    };
