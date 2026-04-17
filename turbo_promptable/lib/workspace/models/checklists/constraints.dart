import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'constraints.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Constraints extends Checklist {
  const Constraints(List<String> items)
    : super(
        name: 'Constraints',
        items: items,
      );

  factory Constraints.fromJson(Map<String, dynamic> json) =>
      _$ConstraintsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ConstraintsToJson(this);
}
