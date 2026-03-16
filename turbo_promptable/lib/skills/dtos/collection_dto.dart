import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'collection_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class CollectionDto extends TurboPromptable {
  CollectionDto({
    required this.items,
  });

  final List<String> items;

  static const fromJsonFactory = _$CollectionDtoFromJson;
  factory CollectionDto.fromJson(Map<String, dynamic> json) =>
      _$CollectionDtoFromJson(json);
  static const toJsonFactory = _$CollectionDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$CollectionDtoToJson(this);

  @override
  String toString() => 'CollectionDto{items: $items}';

  CollectionDto copyWith({
    List<String>? items,
  }) => CollectionDto(
    items: items ?? this.items,
  );
}
