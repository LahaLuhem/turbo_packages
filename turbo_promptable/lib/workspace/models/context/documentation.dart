import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'documentation.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Documentation extends Context {
  Documentation({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Documentation Function(Map<String, dynamic> json) fromJsonFactory =
      _$DocumentationFromJson;
  factory Documentation.fromJson(Map<String, dynamic> json) =>
      _$DocumentationFromJson(json);
  static final Map<String, dynamic> Function(Documentation value) toJsonFactory =
      _$DocumentationToJson;
  @override
  Map<String, dynamic> toJson() => _$DocumentationToJson(this);
}
