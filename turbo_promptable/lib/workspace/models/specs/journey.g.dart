// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TJourney _$TJourneyFromJson(Map<String, dynamic> json) => TJourney(
  name: json['name'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TJourneyToJson(TJourney instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
};
