import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'reference.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Reference extends TPromptable {
  Reference({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Reference Function(Map<String, dynamic> json) fromJsonFactory =
      _$ReferenceFromJson;
  factory Reference.fromJson(Map<String, dynamic> json) =>
      _$ReferenceFromJson(json);
  static final Map<String, dynamic> Function(Reference value) toJsonFactory =
      _$ReferenceToJson;
  @override
  Map<String, dynamic> toJson() => _$ReferenceToJson(this);
}
