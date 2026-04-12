import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import 'package:turbo_firestore_api/generators/t_dummy_schema.dart';
import 'package:turbo_firestore_api/generators/t_value_generator.dart';

/// Sentinel returned by bundled field resolvers when the requested type is
/// incompatible with the heuristic's output domain.
const Object _notApplicable = _Sentinel();

class _Sentinel {
  const _Sentinel();
}

/// Signature for bundled field-name heuristics that are type-aware.
typedef _BundledFieldResolver = Object? Function(Type requestedType);

/// Central value-resolution registry for dummy document generation.
///
/// Resolves a fake value for any (field, type) pair by walking a strict
/// priority order: caller field override → caller type override → bundled
/// field exact match → bundled field substring/suffix match → bundled type
/// fallback → unresolved placeholder → null.
final class TValueGeneratorRegistry {
  TValueGeneratorRegistry._({
    required Map<String, TValueGenerator> callerFieldGenerators,
    required Map<Type, TValueGenerator> callerTypeGenerators,
    required Map<String, _BundledFieldResolver> bundledFieldResolvers,
    required List<String> bundledHeuristicOrder,
    required Map<Type, TValueGenerator> bundledTypeGenerators,
    required Set<String> unresolvedFields,
  })  : _callerFieldGenerators = callerFieldGenerators,
        _callerTypeGenerators = callerTypeGenerators,
        _bundledFieldResolvers = bundledFieldResolvers,
        _bundledHeuristicOrder = bundledHeuristicOrder,
        _bundledTypeGenerators = bundledTypeGenerators,
        _unresolvedFields = unresolvedFields;

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\


  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// Caller-supplied field-name overrides (exact match, highest priority).
  final Map<String, TValueGenerator> _callerFieldGenerators;

  /// Caller-supplied type overrides (exact match, second priority).
  final Map<Type, TValueGenerator> _callerTypeGenerators;

  /// Bundled field-name heuristic resolvers keyed by normalized name.
  final Map<String, _BundledFieldResolver> _bundledFieldResolvers;

  /// Bundled heuristic keys sorted by descending length then declaration order.
  final List<String> _bundledHeuristicOrder;

  /// Bundled runtime-type fallbacks.
  final Map<Type, TValueGenerator> _bundledTypeGenerators;

  /// Field names from the schema that could not be resolved during probing.
  final Set<String> _unresolvedFields;

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Placeholder value for unresolved String fields.
  @visibleForTesting
  static const String placeholderString = '[dummy]';

  /// Placeholder value for unresolved int fields.
  @visibleForTesting
  static const int placeholderInt = 0;

  /// Placeholder value for unresolved double fields.
  @visibleForTesting
  static const double placeholderDouble = 0.0;

  /// Placeholder value for unresolved bool fields.
  @visibleForTesting
  static const bool placeholderBool = false;

  /// Placeholder value for unresolved DateTime fields.
  @visibleForTesting
  static final DateTime placeholderDateTime = DateTime.utc(1970);

  /// Placeholder value for unresolved Timestamp fields.
  @visibleForTesting
  static final Timestamp placeholderTimestamp =
      Timestamp.fromDate(DateTime.utc(1970));

  /// Placeholder value for unresolved List fields.
  @visibleForTesting
  static const List<dynamic> placeholderList = <dynamic>[];

  /// Placeholder value for unresolved Map fields.
  @visibleForTesting
  static const Map<String, dynamic> placeholderMap = <String, dynamic>{};

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Resolves a fake value for the given [field] name and runtime [type].
  dynamic generate({
    required String field,
    required Type type,
  }) {
    // 1. Caller field override (exact match).
    final fieldGen = _callerFieldGenerators[field];
    if (fieldGen != null) return fieldGen();

    // 2. Caller type override (exact match).
    final typeGen = _callerTypeGenerators[type];
    if (typeGen != null) return typeGen();

    // 3. Bundled field exact match.
    final exactResolver = _bundledFieldResolvers[field.toLowerCase()];
    if (exactResolver != null) {
      final result = exactResolver(type);
      if (result is! _Sentinel) return result;
    }

    // 4. Bundled field substring/suffix heuristic.
    final tokens = _tokenize(field);
    for (final heuristicKey in _bundledHeuristicOrder) {
      if (_tokensContainSuffix(tokens, heuristicKey)) {
        final resolver = _bundledFieldResolvers[heuristicKey]!;
        final result = resolver(type);
        if (result is! _Sentinel) return result;
      }
    }

    // 5. Unresolved placeholder (before type fallback so placeholders are visible).
    if (_unresolvedFields.contains(field)) {
      return _placeholderForType(type);
    }

    // 6. Bundled type fallback.
    final bundledType = _bundledTypeGenerators[type];
    if (bundledType != null) return bundledType();

    // 7. No match.
    return null;
  }

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  /// Returns a placeholder value appropriate for [type].
  static dynamic _placeholderForType(Type type) {
    if (type == String) return placeholderString;
    if (type == int) return placeholderInt;
    if (type == double) return placeholderDouble;
    if (type == bool) return placeholderBool;
    if (type == DateTime) return placeholderDateTime;
    if (type == Timestamp) return placeholderTimestamp;
    if (type == List || type == List<dynamic>) return placeholderList;
    if (type == Map || type == Map<String, dynamic>) return placeholderMap;
    return null;
  }

  /// Tokenizes a field name by camelCase boundaries and separators.
  static List<String> _tokenize(String field) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < field.length; i++) {
      final char = field[i];

      // Separator boundary.
      if (char == '_' || char == '-' || char == ' ' || char == '.') {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString().toLowerCase());
          buffer.clear();
        }
        continue;
      }

      // CamelCase boundary: lowercase followed by uppercase.
      if (buffer.isNotEmpty &&
          _isUpperCase(char) &&
          i > 0 &&
          _isLowerCase(field[i - 1])) {
        tokens.add(buffer.toString().toLowerCase());
        buffer.clear();
      }

      // Digit/letter boundary.
      if (buffer.isNotEmpty && i > 0) {
        final prevIsDigit = _isDigit(field[i - 1]);
        final currIsDigit = _isDigit(char);
        if (prevIsDigit != currIsDigit) {
          tokens.add(buffer.toString().toLowerCase());
          buffer.clear();
        }
      }

      buffer.write(char);
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString().toLowerCase());
    }

    return tokens;
  }

  /// Checks whether [tokens] ends with a contiguous sub-sequence that matches
  /// the normalized [heuristicKey] when joined.
  static bool _tokensContainSuffix(List<String> tokens, String heuristicKey) {
    // Build all contiguous suffix windows and check for match.
    for (var start = tokens.length - 1; start >= 0; start--) {
      final window = tokens.sublist(start).join();
      if (window == heuristicKey) return true;
    }
    return false;
  }

  static bool _isUpperCase(String c) => c == c.toUpperCase() && c != c.toLowerCase();
  static bool _isLowerCase(String c) => c == c.toLowerCase() && c != c.toUpperCase();
  static bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  // 🏭 FACTORY ------------------------------------------------------------------------------- \\

  /// Builds a registry by merging caller overrides on top of bundled defaults.
  factory TValueGeneratorRegistry.build({
    Map<String, TValueGenerator>? fieldGenerators,
    Map<Type, TValueGenerator>? typeGenerators,
    required TDummySchema schema,
    required Random random,
  }) {
    final bundledFieldResolvers = _buildBundledFieldResolvers(random);
    final bundledHeuristicOrder = bundledFieldResolvers.keys.toList()
      ..sort((a, b) {
        // Longer keys first for specificity; declaration order preserved for ties
        // since Dart maps preserve insertion order.
        final lengthCmp = b.length.compareTo(a.length);
        return lengthCmp;
      });

    return TValueGeneratorRegistry._(
      callerFieldGenerators: Map<String, TValueGenerator>.of(
        fieldGenerators ?? const {},
      ),
      callerTypeGenerators: Map<Type, TValueGenerator>.of(
        typeGenerators ?? const {},
      ),
      bundledFieldResolvers: bundledFieldResolvers,
      bundledHeuristicOrder: bundledHeuristicOrder,
      bundledTypeGenerators: _buildBundledTypeGenerators(random),
      unresolvedFields: Set<String>.of(schema.unresolved),
    );
  }

  /// Builds the bundled field-name heuristic resolver table.
  static Map<String, _BundledFieldResolver> _buildBundledFieldResolvers(
    Random random,
  ) {
    // -- Data pools --
    const firstNames = [
      'Alice', 'Bob', 'Carol', 'Dave', 'Eve', 'Frank', 'Grace', 'Hank',
      'Iris', 'Jack', 'Kate', 'Leo', 'Mia', 'Nate', 'Olga', 'Pete',
    ];
    const lastNames = [
      'Smith', 'Jones', 'Brown', 'Davis', 'Clark', 'Lopez', 'Adams', 'Baker',
      'Carter', 'Evans', 'Garcia', 'Hall', 'King', 'Lee', 'Moore', 'Perez',
    ];
    const loremWords = [
      'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing',
      'elit', 'sed', 'do', 'eiusmod', 'tempor', 'incididunt', 'ut', 'labore',
      'et', 'dolore', 'magna', 'aliqua', 'enim', 'ad', 'minim', 'veniam',
      'quis', 'nostrud', 'exercitation', 'ullamco', 'laboris', 'nisi',
      'aliquip', 'ex', 'ea', 'commodo', 'consequat',
    ];
    const cities = [
      'New York', 'London', 'Tokyo', 'Paris', 'Berlin', 'Sydney',
      'Toronto', 'Amsterdam',
    ];
    const countries = [
      'United States', 'United Kingdom', 'Japan', 'France', 'Germany',
      'Australia', 'Canada', 'Netherlands',
    ];
    const streets = [
      'Main Street', 'Oak Avenue', 'Park Road', 'Elm Drive', 'Cedar Lane',
      'Maple Boulevard', 'Pine Street', 'Birch Way',
    ];

    // Deterministic timestamp anchor — 2025-01-01 UTC.
    final anchor = DateTime.utc(2025);

    // -- Helper closures --
    String randomFirstName() => firstNames[random.nextInt(firstNames.length)];
    String randomLastName() => lastNames[random.nextInt(lastNames.length)];
    String loremSentence(int wordCount) {
      final words = List.generate(
        wordCount,
        (_) => loremWords[random.nextInt(loremWords.length)],
      );
      return words.join(' ');
    }

    DateTime randomPastDate() {
      final daysAgo = random.nextInt(365) + 1;
      return anchor.subtract(Duration(days: daysAgo));
    }

    _BundledFieldResolver stringOnly(String Function() gen) {
      return (Type type) {
        if (type == String) return gen();
        return _notApplicable;
      };
    }

    _BundledFieldResolver boolOnly(bool Function() gen) {
      return (Type type) {
        if (type == bool) return gen();
        return _notApplicable;
      };
    }

    _BundledFieldResolver dateTimeOrTimestamp(DateTime Function() gen) {
      return (Type type) {
        if (type == DateTime) return gen();
        if (type == Timestamp) return Timestamp.fromDate(gen());
        return _notApplicable;
      };
    }

    _BundledFieldResolver intOrNum(int Function() gen) {
      return (Type type) {
        if (type == int || type == num) return gen();
        return _notApplicable;
      };
    }

    _BundledFieldResolver doubleOrNum(double Function() gen) {
      return (Type type) {
        if (type == double || type == num) return gen();
        return _notApplicable;
      };
    }

    var idCounter = 0;

    // Build resolvers keyed by lowercase field name.
    return <String, _BundledFieldResolver>{
      // Identity fields.
      'id': stringOnly(() => 'dummy_id_${idCounter++}'),
      'uid': stringOnly(() => 'dummy_uid_${idCounter++}'),
      'userid': stringOnly(() => 'dummy_userid_${idCounter++}'),
      'ownerid': stringOnly(() => 'dummy_ownerid_${idCounter++}'),

      // Name fields.
      'firstname': stringOnly(randomFirstName),
      'lastname': stringOnly(randomLastName),
      'fullname': stringOnly(
        () => '${randomFirstName()} ${randomLastName()}',
      ),
      'displayname': stringOnly(
        () => '${randomFirstName()} ${randomLastName()}',
      ),
      'name': stringOnly(
        () => '${randomFirstName()} ${randomLastName()}',
      ),

      // Handle fields.
      'username': stringOnly(
        () => '${randomFirstName().toLowerCase()}${random.nextInt(9999)}',
      ),
      'email': stringOnly(
        () => '${randomFirstName().toLowerCase()}${random.nextInt(9999)}'
            '@example.com',
      ),
      'phone': stringOnly(
        () => '+1-555-${random.nextInt(900) + 100}-'
            '${random.nextInt(9000) + 1000}',
      ),
      'phonenumber': stringOnly(
        () => '+1-555-${random.nextInt(900) + 100}-'
            '${random.nextInt(9000) + 1000}',
      ),

      // Text fields.
      'description': stringOnly(() => loremSentence(8)),
      'summary': stringOnly(() => loremSentence(6)),
      'title': stringOnly(() => loremSentence(3)),
      'content': stringOnly(() => loremSentence(20)),
      'body': stringOnly(() => loremSentence(20)),

      // URL fields.
      'url': stringOnly(
        () => 'https://example.com/${loremWords[random.nextInt(loremWords.length)]}',
      ),
      'avatarurl': stringOnly(
        () => 'https://example.com/avatars/${random.nextInt(1000)}.png',
      ),
      'imageurl': stringOnly(
        () => 'https://example.com/images/${random.nextInt(1000)}.png',
      ),
      'thumbnailurl': stringOnly(
        () => 'https://example.com/thumbnails/${random.nextInt(1000)}.png',
      ),

      // Address fields.
      'address': stringOnly(
        () => '${random.nextInt(9999) + 1} ${streets[random.nextInt(streets.length)]}',
      ),
      'street': stringOnly(
        () => streets[random.nextInt(streets.length)],
      ),
      'city': stringOnly(
        () => cities[random.nextInt(cities.length)],
      ),
      'country': stringOnly(
        () => countries[random.nextInt(countries.length)],
      ),
      'zip': (Type type) {
        if (type == String) return '${random.nextInt(90000) + 10000}';
        if (type == int || type == num) return random.nextInt(90000) + 10000;
        return _notApplicable;
      },
      'postalcode': (Type type) {
        if (type == String) return '${random.nextInt(90000) + 10000}';
        if (type == int || type == num) return random.nextInt(90000) + 10000;
        return _notApplicable;
      },

      // Timestamp fields.
      'createdat': dateTimeOrTimestamp(randomPastDate),
      'updatedat': dateTimeOrTimestamp(randomPastDate),
      'deletedat': dateTimeOrTimestamp(randomPastDate),
      'timestamp': dateTimeOrTimestamp(randomPastDate),

      // Numeric fields.
      'age': intOrNum(() => random.nextInt(80) + 18),
      'count': intOrNum(() => random.nextInt(1000)),
      'quantity': intOrNum(() => random.nextInt(100)),
      'price': doubleOrNum(
        () => random.nextInt(100000) / 100,
      ),
      'amount': doubleOrNum(
        () => random.nextInt(100000) / 100,
      ),
      'rating': doubleOrNum(
        () => random.nextInt(50) / 10,
      ),
      'score': doubleOrNum(
        () => random.nextInt(1000) / 10,
      ),

      // Boolean fields.
      'isactive': boolOnly(() => random.nextBool()),
      'isdeleted': boolOnly(() => random.nextBool()),
      'enabled': boolOnly(() => random.nextBool()),
    };
  }

  /// Builds the bundled runtime-type fallback table.
  static Map<Type, TValueGenerator> _buildBundledTypeGenerators(
    Random random,
  ) {
    const words = [
      'alpha', 'bravo', 'charlie', 'delta', 'echo', 'foxtrot', 'golf',
      'hotel', 'india', 'juliet', 'kilo', 'lima', 'mike', 'november',
    ];
    final anchor = DateTime.utc(2025);

    return <Type, TValueGenerator>{
      String: () => words[random.nextInt(words.length)],
      int: () => random.nextInt(1001),
      double: () => random.nextInt(100000) / 100,
      num: () => random.nextInt(1001),
      bool: () => random.nextBool(),
      DateTime: () => anchor.subtract(Duration(days: random.nextInt(365) + 1)),
      Timestamp: () => Timestamp.fromDate(
            anchor.subtract(Duration(days: random.nextInt(365) + 1)),
          ),
      List<dynamic>: () => const <dynamic>[],
      Map<String, dynamic>: () => const <String, dynamic>{},
      GeoPoint: () => GeoPoint(
            (random.nextDouble() * 180) - 90,
            (random.nextDouble() * 360) - 180,
          ),
      DocumentReference<Map<String, dynamic>>: () => null,
      Blob: () => Blob(Uint8List(0)),
    };
  }
}
