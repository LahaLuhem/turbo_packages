import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'subject.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Subject extends Context {
  Subject({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Subject Function(Map<String, dynamic> json) fromJsonFactory =
      _$SubjectFromJson;
  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
  static final Map<String, dynamic> Function(Subject value) toJsonFactory =
      _$SubjectToJson;
  @override
  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
