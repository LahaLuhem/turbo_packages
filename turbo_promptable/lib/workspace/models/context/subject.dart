import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'subject.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Subject extends Context {
  const Subject({
    required super.name,
  });

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
