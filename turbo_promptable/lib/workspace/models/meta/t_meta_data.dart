import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/constants/tp_keys.dart';
import 'package:turbo_promptable/core/extensions/t_collection_extensions.dart';
import 'package:turbo_promptable/workspace/models/meta/t_tag.dart';

part 't_meta_data.g.dart';

typedef TFrontMatter = TMetaData;

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TMetaData {
  TMetaData({
    required this.description,
    required this.name,
    this.aliases,
    this.emoji,
    this.tags,
    this.values,
  });

  final List<String>? aliases;
  final List<TTag>? tags;
  @JsonKey(fromJson: _valuesFromJson, toJson: _valuesToJson)
  final Map<String, Object>? values;
  final String? description;
  final String? emoji;
  final String? name;

  factory TMetaData.fromJson(Map<String, dynamic> json) =>
      _$TMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$TMetaDataToJson(this);

  static Map<String, Object>? _valuesFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return json.map((k, v) => MapEntry(k, v as Object));
  }

  static Map<String, dynamic>? _valuesToJson(Map<String, Object>? values) {
    if (values == null) return null;
    return Map<String, dynamic>.from(values);
  }

  Map<String, String> toMap() => {
    if (aliases != null) TpKeys.aliases: aliases!.toArrayString(),
    if (description != null) TpKeys.description: description!,
    if (emoji != null) TpKeys.emoji: emoji!,
    if (name != null) TpKeys.name: name!,
    if (tags != null) TpKeys.tags: tags!.toArrayString(),
    if (values != null)
      for (var entry in values!.entries) entry.key: entry.value.toString(),
  };
}
