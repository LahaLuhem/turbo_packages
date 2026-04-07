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
    if (name != null) 'name': name!,
    if (description != null) 'description': description!,
    if (tags != null) 'tags': tags!.toArrayString(),
    if (aliases != null) 'aliases': aliases!.toArrayString(),
    if (values != null)
      for (var entry in values!.entries) entry.key: entry.value.toString(),
  };
}
