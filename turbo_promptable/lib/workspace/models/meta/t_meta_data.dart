import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_tag.dart';
import 'package:turbo_serializable/abstracts/t_serializable.dart';

part 't_meta_data.g.dart';

typedef TFrontMatter = TMetaData;

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TMetaData extends TSerializable {
  const TMetaData({
    required this.description,
    required this.name,
    this.aliases,
    this.emoji,
    this.tags,
  });

  final List<String>? aliases;
  final List<TTag>? tags;
  final String? description;
  final String? emoji;
  final String? name;

  static const fromJsonFactory = _$TMetaDataFromJson;
  factory TMetaData.fromJson(Map<String, dynamic> json) =>
      _$TMetaDataFromJson(json);
  static const toJsonFactory = _$TMetaDataToJson;
  @override
  Map<String, dynamic> toJson() => _$TMetaDataToJson(this);
}
