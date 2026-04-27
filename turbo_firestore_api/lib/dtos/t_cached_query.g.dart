// GENERATED CODE - DO NOT MODIFY BY HAND

part of 't_cached_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TCachedQuery _$TCachedQueryFromJson(Map<String, dynamic> json) => TCachedQuery(
  query: json['query'] as String,
  docIds: (json['docIds'] as List<dynamic>).map((e) => e as String).toSet(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TCachedQueryToJson(TCachedQuery instance) =>
    <String, dynamic>{
      'query': instance.query,
      'docIds': instance.docIds.toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
