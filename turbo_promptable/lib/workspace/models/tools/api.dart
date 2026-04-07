import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';

part 'api.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Api extends Tool {
  Api({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Api Function(Map<String, dynamic> json) fromJsonFactory =
      _$ApiFromJson;
  factory Api.fromJson(Map<String, dynamic> json) => _$ApiFromJson(json);
  static final Map<String, dynamic> Function(Api value) toJsonFactory =
      _$ApiToJson;
  @override
  Map<String, dynamic> toJson() => _$ApiToJson(this);
}
