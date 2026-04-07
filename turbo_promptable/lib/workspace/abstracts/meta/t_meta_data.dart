import 'package:turbo_promptable/core/constants/tp_keys.dart';
import 'package:turbo_promptable/core/extensions/t_collection_extensions.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_tag.dart';

typedef TFrontMatter = TMetaData;

class TMetaData {
  TMetaData({
    required this.name,
    required this.description,
    this.values,
    this.tags,
    this.aliases,
  });

  final String? name;
  final String? description;
  final List<TTag>? tags;
  final List<String>? aliases;
  final Map<String, Object>? values;

  Map<String, String> toMap() => {
    if (name != null) TpKeys.name: name!,
    if (description != null) TpKeys.description: description!,
    if (tags != null) TpKeys.tags: tags!.toArrayString(),
    if (aliases != null) TpKeys.aliases: aliases!.toArrayString(),
    if (values != null)
      for (var entry in values!.entries) entry.key: entry.value.toString(),
  };
}
