import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'documentation.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Documentation extends Context {
  const Documentation({
    required super.name,
  });

  factory Documentation.fromJson(Map<String, dynamic> json) =>
      _$DocumentationFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DocumentationToJson(this);
}
