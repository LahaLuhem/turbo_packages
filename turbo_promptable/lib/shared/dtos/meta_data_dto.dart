import 'package:json_annotation/json_annotation.dart';

part 'meta_data_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class MetaDataDto {
  MetaDataDto({required this.name, required this.description});

  final String? name;
  final String? description;

  static const fromJsonFactory = _$MetaDataDtoFromJson;
  factory MetaDataDto.fromJson(Map<String, dynamic> json) =>
      _$MetaDataDtoFromJson(json);
  static const toJsonFactory = _$MetaDataDtoToJson;
  Map<String, dynamic> toJson() => _$MetaDataDtoToJson(this);

  MetaDataDto copyWith({
    String? name,
    String? description,
  }) {
    return MetaDataDto(
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'MetaDataDto{name: $name, description: $description}';
  }
}
