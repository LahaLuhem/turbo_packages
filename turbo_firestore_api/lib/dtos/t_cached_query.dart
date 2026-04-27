import 'package:json_annotation/json_annotation.dart';

part 't_cached_query.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TCachedQuery {
  TCachedQuery({
    required this.query,
    required this.docs,
    required this.doc,
    required this.createdAt,
    required this.updatedAt,
  }) : id = '$query';

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String id;
  final String query;
  final List<Map<String, dynamic>>? docs;
  final Map<String, dynamic>? doc;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const fromJsonFactory = _$TCachedQueryFromJson;
  factory TCachedQuery.fromJson(Map<String, dynamic> json) => _$TCachedQueryFromJson(json);
  static const toJsonFactory = _$TCachedQueryToJson;
  Map<String, dynamic> toJson() => _$TCachedQueryToJson(this);
}
