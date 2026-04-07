import 'package:turbo_promptable/core/constants/tp_keys.dart';
import 'package:turbo_promptable/core/extensions/t_collection_extensions.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_tag.dart';

typedef TFrontMatter = TMetaData;

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
  final Map<String, Object>? values;
  final String? description;
  final String? emoji;
  final String? name;

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
