// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expertise_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpertiseDto _$ExpertiseDtoFromJson(Map<String, dynamic> json) => ExpertiseDto(
  field: json['field'] as String,
  specialization: json['specialization'] as String,
  experience: json['experience'] as String,
);

Map<String, dynamic> _$ExpertiseDtoToJson(ExpertiseDto instance) =>
    <String, dynamic>{
      'field': instance.field,
      'specialization': instance.specialization,
      'experience': instance.experience,
    };
