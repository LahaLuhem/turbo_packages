// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionDto _$CollectionDtoFromJson(Map<String, dynamic> json) =>
    CollectionDto(
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CollectionDtoToJson(CollectionDto instance) =>
    <String, dynamic>{'items': instance.items};
