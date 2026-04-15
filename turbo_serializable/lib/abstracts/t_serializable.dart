import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';
import 'package:turbo_serializable/extensions/ts_map_extenion.dart';
import 'package:turbo_serializable/markdown/factories/t_md_factory.dart';

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
  }) =>
      yamlBuilder?.call(this, true) ??
      ((writeable) => toJson().toYaml(
        includeMetaData: includeMetaData,
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
  }) {
    final pMdFactory = mdFactory ?? this.mdFactory;
    if (pMdFactory == null) {
      return toJson().toMd(
        includeMetaData: includeMetaData,
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
  }) =>
      xmlBuilder?.call(this, includeMetaData) ??
      ((writeable) => toJson().toXml(
        includeMetaData: includeMetaData,
      ))(this);

  /// Returns a function that builds an XML string from a JSON map.
  ///
  /// Subclasses should override this getter to supply their XML builder, or
  /// set it externally, if applicable. If not provided, [toXml()] will throw.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String Function(TWriteable writeable, bool includeMeta)? xmlBuilder;
}
