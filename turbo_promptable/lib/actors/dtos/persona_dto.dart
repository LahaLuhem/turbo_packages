import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'persona_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class PersonaDto extends TurboPromptable {
  PersonaDto({
    this.achievements,
    this.background,
    this.communicationStyle,
    this.nickname,
    this.preferences,
    this.resume,
    this.values,
  });

  final List<String>? achievements;
  final List<String>? preferences;
  final List<String>? resume;
  final List<String>? values;
  final String? background;
  final String? communicationStyle;
  final String? nickname;

  static const fromJsonFactory = _$PersonaDtoFromJson;
  factory PersonaDto.fromJson(Map<String, dynamic> json) =>
      _$PersonaDtoFromJson(json);
  static const toJsonFactory = _$PersonaDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$PersonaDtoToJson(this);

  PersonaDto copyWith({
    List<String>? achievements,
    List<String>? preferences,
    List<String>? resume,
    List<String>? values,
    String? background,
    String? communicationStyle,
    String? nickname,
  }) {
    return PersonaDto(
      achievements: achievements ?? this.achievements,
      preferences: preferences ?? this.preferences,
      resume: resume ?? this.resume,
      values: values ?? this.values,
      background: background ?? this.background,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      nickname: nickname ?? this.nickname,
    );
  }

  @override
  String toString() =>
      'PersonaDto{achievements: $achievements, preferences: $preferences, resume: $resume, values: $values, background: $background, communicationStyle: $communicationStyle, nickname: $nickname}';
}
