import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

part 'constraints.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Constraints extends Checklist {
  Constraints({
    required super.name,
    required super.items,
    super.config,
  });

  static final Constraints Function(Map<String, dynamic> json) fromJsonFactory =
      _$ConstraintsFromJson;
  factory Constraints.fromJson(Map<String, dynamic> json) =>
      _$ConstraintsFromJson(json);
  static final Map<String, dynamic> Function(Constraints value) toJsonFactory =
      _$ConstraintsToJson;
  @override
  Map<String, dynamic> toJson() => _$ConstraintsToJson(this);
}
