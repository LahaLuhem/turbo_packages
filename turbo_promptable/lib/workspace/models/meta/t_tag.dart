import 'package:json_annotation/json_annotation.dart';

part 't_tag.g.dart';

/// A hashtag-style label attached to [TMetaData] for categorization.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TTag {
  const TTag(this.value);

  final String value;

  factory TTag.fromJson(Map<String, dynamic> json) => _$TTagFromJson(json);
  Map<String, dynamic> toJson() => _$TTagToJson(this);

  @override
  String toString() => '#$value';
}
