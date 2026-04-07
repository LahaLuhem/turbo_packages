import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';

part 'convention.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Convention extends Instruction {
  Convention({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Convention Function(Map<String, dynamic> json) fromJsonFactory =
      _$ConventionFromJson;
  factory Convention.fromJson(Map<String, dynamic> json) =>
      _$ConventionFromJson(json);
  static final Map<String, dynamic> Function(Convention value) toJsonFactory =
      _$ConventionToJson;
  @override
  Map<String, dynamic> toJson() => _$ConventionToJson(this);
}
