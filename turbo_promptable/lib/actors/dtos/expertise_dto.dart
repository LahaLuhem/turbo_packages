import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'expertise_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class ExpertiseDto extends TurboPromptable {
  ExpertiseDto({
    required this.field,
    required this.specialization,
    required this.experience,
  });

  final String field;
  final String specialization;
  final String experience;

  static const fromJsonFactory = _$ExpertiseDtoFromJson;
  factory ExpertiseDto.fromJson(Map<String, dynamic> json) =>
      _$ExpertiseDtoFromJson(json);
  static const toJsonFactory = _$ExpertiseDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$ExpertiseDtoToJson(this);

  @override
  String toString() =>
      'ExpertiseDto{field: $field, specialization: $specialization, experience: $experience}';

  ExpertiseDto copyWith({
    String? field,
    String? specialization,
    String? experience,
  }) => ExpertiseDto(
    field: field ?? this.field,
    specialization: specialization ?? this.specialization,
    experience: experience ?? this.experience,
  );
}
