# turbo_serializable

[![pub package](https://img.shields.io/pub/v/turbo_serializable.svg)](https://pub.dev/packages/turbo_serializable)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Dart 3](https://img.shields.io/badge/Dart-%3E%3D3.6.0-blue.svg)](https://dart.dev)

A minimal serialization abstraction for the turbo ecosystem with optional multi-format support (JSON, YAML, Markdown, XML).

## Features

- **Simple abstraction** - Minimal base classes for serializable objects
- **Multi-format support** - Optional YAML, Markdown, and XML serialization
- **Factory pattern** - `TMdFactory`, `TXmlFactory`, and `TYamlFactory` for structured format building
- **Validation integration** - Built-in validation using `TurboResponse`
- **Typed identifiers** - `TSerializableId` for objects with unique identifiers

## Installation

```yaml
dependencies:
  turbo_serializable: ^0.5.0
```

## Quick Start

```dart
import 'package:turbo_serializable/turbo_serializable.dart';

class User extends TSerializable {
  User({required this.name, required this.age});

  final String name;
  final int age;

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
  };

  @override
  String Function(TWriteable writeable)? yamlBuilder =
      (writeable) {
        final json = writeable.toJson();
        return 'name: ${json['name']}\nage: ${json['age']}';
      };
}

void main() {
  final user = User(name: 'Alice', age: 30);

  print(user.toJson()); // {name: Alice, age: 30}
  print(user.toYaml()); // name: Alice\nage: 30
}
```

## API Reference

### Core Classes

| Class | Description |
|---|---|
| `TWriteable` | Base class providing `toJson()` and `validate()` |
| `TWriteableId` | Extends `TWriteable` with a string identifier |
| `TWriteableCustomId<T>` | Extends `TWriteable` with a typed identifier |
| `TSerializable` | Extends `TWriteable` with YAML, Markdown, and XML serialization |
| `TSerializableId` | Extends `TWriteableCustomId` with YAML, Markdown, and XML serialization |

### TSerializable

| Member | Type | Description |
|---|---|---|
| `toJson()` | `Map<String, dynamic>` | Serialize to JSON map (required override) |
| `toYaml()` | `String` | Serialize via `yamlBuilder`. Throws `UnimplementedError` if null. |
| `toMarkdown()` | `String` | Serialize via `mdFactory`. Returns empty string if null. |
| `toXml()` | `String` | Serialize via `xmlBuilder`. Throws `UnimplementedError` if null. |
| `validate<T>()` | `TurboResponse<T>?` | Returns `null` if valid, `TurboResponse.fail` if invalid |
| `yamlBuilder` | `String Function(TWriteable)?` | Optional YAML builder function |
| `mdFactory` | `TMdFactory?` | Optional Markdown factory |
| `xmlBuilder` | `String Function(Map<String, dynamic>)?` | Optional XML builder function |

### TSerializableId

| Member | Type | Description |
|---|---|---|
| `toJson()` | `Map<String, dynamic>` | Serialize to JSON map (required override) |
| `toYaml()` | `String` | Serialize via `yamlBuilder`. Throws `UnimplementedError` if null. |
| `toMarkdown()` | `String` | Serialize via `markdownBuilder`. Throws `UnimplementedError` if null. |
| `toXml()` | `String` | Serialize via `xmlBuilder`. Throws `UnimplementedError` if null. |
| `id` | `dynamic` | Unique identifier (required override) |
| `yamlBuilder` | `String Function(Map<String, dynamic>)?` | Optional YAML builder getter |
| `markdownBuilder` | `String Function(Map<String, dynamic>)?` | Optional Markdown builder getter |
| `xmlBuilder` | `String Function(Map<String, dynamic>)?` | Optional XML builder getter |

### Format Factories

| Factory | Description |
|---|---|
| `TMdFactory<T>` | Structured Markdown builder with frontmatter, sections, body, and file stages |
| `TXmlFactory<T>` | Structured XML builder with document and file stages |
| `TYamlFactory<T>` | Structured YAML builder with document and file stages |

## Examples

### Basic Serializable Object

```dart
class User extends TSerializable {
  User({required this.name, required this.age});

  final String name;
  final int age;

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
  };
}
```

### With Identifier

```dart
class Product extends TSerializableId {
  Product({required this.id, required this.name});

  @override
  final String id;
  final String name;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
```

### With Validation

```dart
class User extends TSerializable {
  User({required this.name, required this.age});

  final String name;
  final int age;

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
  };

  @override
  TurboResponse<T>? validate<T>() {
    if (name.isEmpty) {
      return TurboResponse.fail(error: 'Name cannot be empty');
    }
    if (age < 0) {
      return TurboResponse.fail(error: 'Age cannot be negative');
    }
    return null;
  }
}
```

### Using TMdFactory

```dart
class Article extends TSerializable {
  Article({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
  };

  @override
  TMdFactory? get mdFactory => TMdFactory(
    writeable: this,
    mdBuilder: (writeable, frontmatter, sections, body) {
      final json = writeable.toJson();
      return '# ${json['title']}\n\n${json['content']}';
    },
  );
}
```

## Error Handling

- `toYaml()` and `toXml()` throw `UnimplementedError` if the corresponding builder is `null`
- `toMarkdown()` on `TSerializable` returns an empty string if `mdFactory` is `null`
- `toMarkdown()` on `TSerializableId` throws `UnimplementedError` if `markdownBuilder` is `null`
- `validate()` returns `null` if valid, or `TurboResponse.fail` if invalid

## Additional Information

- [API Documentation](https://pub.dev/documentation/turbo_serializable/latest/)
- [GitHub Repository](https://github.com/appboypov/turbo_packages/tree/main/turbo_serializable)
- [Issue Tracker](https://github.com/appboypov/turbo_packages/issues)

## License

MIT
