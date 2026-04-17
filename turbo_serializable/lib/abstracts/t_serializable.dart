import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';
import 'package:turbo_serializable/constants/ts_defaults.dart';
import 'package:turbo_serializable/extensions/ts_map_extension.dart';
import 'package:turbo_serializable/markdown/factories/t_md_factory.dart';
import 'package:turbo_serializable/typedefs/key_value_builder_def.dart';

/// Abstract base class providing serialization to multiple data formats.
///
/// Extends [TWriteable] and provides convenience methods for converting
/// the object into YAML, Markdown, and XML representations.
/// Requires concrete implementations to provide builder functions for
/// each format they wish to support.
abstract class TSerializable extends TWriteable {
  const TSerializable({
    this.yamlBuilder,
    this.mdFactory,
    this.xmlBuilder,
  });

  /// Converts this object to a YAML string.
  ///
  /// Uses [yamlBuilder] to serialize the result of [toJson()].
  String toYaml({
    bool includeMetaData = true,
    KeyValueBuilderDef? keyBuilder,
    String metaDataKey = TSDefaults.metaDataKey,
    KeyValueBuilderDef? listItemBuilder,
  }) =>
      yamlBuilder?.call(this, true) ??
      ((writeable) => toJson().toYaml(
        includeMetaData: includeMetaData,
        metaDataKey: metaDataKey,
        keyBuilder: keyBuilder,
        listItemBuilder: listItemBuilder,
      ))(this);

  /// Returns a function that builds a YAML string from a JSON map.
  ///
  /// Subclasses should override this getter to supply their YAML builder, or
  /// set it externally, if applicable. If not provided, [toYaml()] will throw.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String Function(TWriteable writeable, bool includeMetaData)?
  yamlBuilder;

  /// Converts this object to a Markdown string.
  ///
  /// Uses [mdFactory] to serialize the result of [toJson()].
  String toMd({
    TMdFactory? mdFactory,
    bool includeMetaData = true,
    int headingLevel = 1,
    KeyValueBuilderDef? titleBuilder,
    KeyValueBuilderDef? listItemBuilder,
    String metaDataKey = TSDefaults.metaDataKey,
    String emojiKey = TSDefaults.emojiKey,
    String nameKey = TSDefaults.nameKey,
    String descriptionKey = TSDefaults.descriptionKey,
    String valueKey = TSDefaults.valueKey,
    String valuesKey = TSDefaults.valuesKey,
    String itemsKey = TSDefaults.itemsKey,
  }) {
    final pMdFactory = mdFactory ?? this.mdFactory;
    if (pMdFactory == null) {
      return toJson().toMd(
        metaDataToFrontMatter: includeMetaData,
        headingLevel: headingLevel,
        titleBuilder: titleBuilder,
        listItemBuilder: listItemBuilder,
        frontMatterKey: metaDataKey,
        emojiKey: emojiKey,
        nameKey: nameKey,
        descriptionKey: descriptionKey,
        valueKey: valueKey,
        valuesKey: valuesKey,
        itemsKey: itemsKey,
      );
    }
    return includeMetaData ? pMdFactory.build() : pMdFactory.buildBody();
  }

  /// Returns a function that builds a Markdown string from a JSON map.
  ///
  /// Subclasses should override this getter to supply their Markdown builder, or
  /// set it externally, if applicable.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final TMdFactory? mdFactory;

  /// Converts this object to an XML string.
  ///
  /// Uses [xmlBuilder] to serialize the result of [toJson()].
  String toXml({
    bool includeMetaData = true,
    KeyValueBuilderDef? keyBuilder,
    KeyValueBuilderDef? listItemBuilder,
    String metaDataKey = TSDefaults.metaDataKey,
  }) =>
      xmlBuilder?.call(this, includeMetaData) ??
      ((writeable) => toJson().toXml(
        includeMetaData: includeMetaData,
        metaDataKey: metaDataKey,
        keyBuilder: keyBuilder,
        listItemBuilder: listItemBuilder,
      ))(this);

  /// Returns a function that builds an XML string from a JSON map.
  ///
  /// Subclasses should override this getter to supply their XML builder, or
  /// set it externally, if applicable. If not provided, [toXml()] will throw.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String Function(TWriteable writeable, bool includeMeta)? xmlBuilder;
}
