# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2026-04-15

### Fixed
- Exclude stray `pubspec.yaml.workspace` from the published tarball (via `.pubignore`) so consumers do not receive backup artifacts.

## [0.4.1] - 2026-04-15

### Fixed
- Remove `resolution: workspace` from the published pubspec so pub.dev clients and `pana` downgrade tests can resolve this package (workspace-only metadata must not appear in published artifacts).

## [0.4.0] - 2026-04-15

### Changed
- **BREAKING**: Remove Dart source rendering from `TSerializable` (optional emitter hook and related constructor wiring). JSON, YAML, Markdown, and XML output are unchanged.

## [0.3.2] - 2026-04-13

### Changed
- Release notes corrected: Dart source emission hooks shipped in this tag were removed in 0.4.0; see 0.4.0 for the breaking cleanup.

## [0.3.1] - 2026-04-10

### Changed
- Widened `TMdFrontmatter` typedef from `Map<String, String>` to `Map<String, dynamic>` to support non-string frontmatter values

## [0.3.0] - 2026-01-31

### Added
- Simplified abstract base classes: `TSerializable` and `TSerializableId`
- Builder-based serialization pattern with optional format builders (`yamlBuilder`, `markdownBuilder`, `xmlBuilder`)
- `TMdFactory` markdown factory with section-based builder pattern and typedefs (`TMdSectionsBuilder`, `TMdSectionBuilder`, `TMdBodyBuilder`, `TMdHeaderBuilder`)
- `TXmlFactory` XML factory with element-based builder pattern and typedefs (`TXmlRootBuilder`, `TXmlElementsBuilder`, `TXmlElementBuilder`)
- `TYamlFactory` YAML factory with entry-based builder pattern and typedefs (`TYamlEntriesBuilder`, `TYamlEntryBuilder`)
- Comprehensive Dart documentation for all classes and methods
- Example project demonstrating simplified API usage

### Changed
- **BREAKING**: Renamed all classes to t-prefix convention (`TurboSerializable` → `TSerializable`, `TurboWriteable` → `TWriteable`)
- **BREAKING**: Removed `TurboSerializableConfig` - serialization methods are now implemented directly via overrides
- **BREAKING**: Removed all format converter functions (`jsonToYaml`, `yamlToJson`, etc.)
- **BREAKING**: Removed all parsers and generators (layout-aware parsing, format conversion utilities)
- **BREAKING**: Removed metadata support (`metaData` parameter, `HasToJson` interface)
- **BREAKING**: Removed `isLocalDefault` parameter from ID-based classes
- **BREAKING**: Removed case transformation utilities and `CaseStyle` enum
- **BREAKING**: Removed layout preservation features and related models
- `TSerializable.toMarkdown()` now uses `TMdFactory` instead of a simple builder function
- Simplified API to focus on core serialization abstraction
- Updated example project to demonstrate new simplified API

### Removed
- All format converter functions (12 conversion functions)
- All parsers (`json_parser`, `yaml_parser`, `markdown_parser`, `xml_parser`)
- All generators (`json_generator`, `yaml_generator`, `markdown_generator`, `xml_generator`)
- Configuration classes (`TurboSerializableConfig`, `TurboConstants`)
- Metadata models (`KeyMetadata`, `LayoutAwareParseResult`, format-specific metadata)
- Utility classes (`CaseConverter`, `HasToJson` interface)
- Enums (`CaseStyle`, `SerializationFormat`)
- Comprehensive test suite and integration tests

### Fixed
- Unresolvable dartdoc references in `TSerializable` and `TSerializableId`
- `dart format` issues in factory and typedef files
- Export directive ordering in barrel file

### Technical Details
- Package now provides minimal abstraction layer for serialization
- Focus on core functionality: `toJson()`, `validate()`, and optional format builders
- Reduced complexity from multi-format conversion system to simple serialization base classes
- Maintains compatibility with `turbo_response` for validation
- All serialization format support is now optional and implemented via builder functions or factory classes

## [0.2.0] - 2026-01-12

### Added
- Layout-aware parsers for YAML, Markdown, XML, and JSON with metadata extraction
- Layout generators for YAML and Markdown that preserve original formatting
- `LayoutAwareParseResult` model for returning both data and key-level metadata
- `KeyMetadata` model for storing per-key layout information
- Format-specific metadata models: `YamlMeta`, `MarkdownMeta`, `XmlMeta`, `JsonMeta`
- `preserveLayout` parameter to all format conversion functions for round-trip fidelity
- Support for YAML anchors, aliases, comments, and scalar styles preservation
- Support for XML attributes, CDATA, namespaces, and comments preservation
- Support for Markdown header levels, list styles, and formatting preservation

### Changed
- Format converter functions now properly extract and pass `keyMeta` from `LayoutAwareParseResult`
- Conversion functions pass `preserveLayout` through to output generators instead of forcing `false`
- Improved documentation for `preserveLayout` parameter behavior

### Technical Details
- Layout parsers extract metadata during parsing without modifying data structure
- Layout generators use metadata to reconstruct original formatting
- Enables byte-for-byte round-trip fidelity when converting between formats
- Backward compatible: `preserveLayout` defaults to `false` for parsing, `true` for generation

## [0.1.2] - 2026-01-11

### Added
- `TurboSerializableConfig` class for configuring serialization callbacks
- Export of `TurboSerializableConfig` from main library for easier imports
- Case converter utility (`convertCase`) for flexible string casing transformations
- Case style support for serialization in `TurboSerializable` with `CaseStyle` enum
- `TurboConstants` class for centralized constant management
- Enhanced `markdownToYaml` function with `metaData`, `includeNulls`, and `prettyPrint` parameters
- Enhanced serialization methods with `includeNulls` and `prettyPrint` options
- Comprehensive architectural documentation and specifications
- Expanded testing guidelines and documentation structure

### Changed
- Refactored `TurboSerializable` to use `TurboSerializableConfig` for serialization method configuration
- Standardized callback names in `TurboSerializableConfig`:
  - `toJsonCallback` → `toJson`
  - `toYamlString` → `toYaml`
  - `toMarkdownString` → `toMarkdown`
- Primary format is now automatically determined from provided callbacks (priority: json > yaml > markdown > xml)
- Updated `toXml` method to include `includeMetaData` parameter
- Renamed `mapToXml` to `jsonToXml` for consistency in XML conversion

### Fixed
- Function naming consistency in XML converter (`mapToXml` → `jsonToXml`)

### Technical Details
- Introduced `HasToJson` interface for metadata types that can be serialized to JSON
- Removed deprecated `toJsonImpl` methods in favor of callback-based implementations
- Enhanced documentation to guide users on the new configuration setup
- Ensured backward compatibility with existing serialization methods where applicable

## [0.1.1] - 2026-01-11

### Changed
- Rewrote README with Library/Package format: badges, features list, API reference tables, focused examples
- Reduced README from 329 to 90 lines (73% reduction)

## [0.1.0] - 2026-01-11

### Added
- Standalone format converter functions: `jsonToYaml`, `jsonToMarkdown`, `jsonToXml`, `yamlToJson`, `yamlToMarkdown`, `yamlToXml`, `markdownToJson`, `markdownToYaml`, `markdownToXml`, `xmlToJson`, `xmlToYaml`, `xmlToMarkdown`
- `jsonToXml` and `xmlToMap` functions for direct JSON/XML conversion
- Markdown-to-JSON parsing with YAML frontmatter support
- JSON-to-Markdown conversion with header-based format (keys become `##`, `###`, `####`, `**bold**` at level 5+)
- Title Case conversion for markdown headers
- PascalCase option for XML element names
- Metadata support for all format conversions
- Comprehensive integration test suite with 284 tests
- Edge case sample files covering: deep nesting, unicode/emoji, empty collections, YAML anchors/aliases, XML declarations, and format-specific features

### Changed
- Removed deprecated `from*` instance methods (use standalone converter functions instead)

### Fixed
- XML converter uses `XmlText.value` instead of deprecated `XmlData.text`

## [0.0.1] - 2026-01-11

### Added
- Initial release
- `TurboSerializable<M>` abstract class with optional serialization methods and typed metadata support
- `TurboSerializableId<T, M>` with typed identifier and metadata support
- Optional `metaData` field for frontmatter and auxiliary data
- Supported formats: JSON, YAML, Markdown, XML
