part of 't_dummy_firestore_api.dart';

// ---------------------------------------------------------------------------
// Candidate system
// ---------------------------------------------------------------------------

/// Ordered candidate types the probing map tries for each field.
enum _CandidateTag {
  string,
  int_,
  double_,
  num_,
  bool_,
  dateTime,
  timestamp,
  listDynamic,
  mapStringDynamic,
  geoPoint,
  documentReference,
  blob,
  null_,
}

/// The concrete runtime [Type] each candidate emits as a [TDummySchemaLeaf].
final Map<_CandidateTag, Type> _candidateLeafTypes = {
  _CandidateTag.string: String,
  _CandidateTag.int_: int,
  _CandidateTag.double_: double,
  _CandidateTag.num_: num,
  _CandidateTag.bool_: bool,
  _CandidateTag.dateTime: DateTime,
  _CandidateTag.timestamp: Timestamp,
  _CandidateTag.listDynamic: List<dynamic>,
  _CandidateTag.mapStringDynamic: Map<String, dynamic>,
  _CandidateTag.geoPoint: GeoPoint,
  _CandidateTag.documentReference: DocumentReference<Map<String, dynamic>>,
  _CandidateTag.blob: Blob,
  // null_ has no meaningful leaf type — treated as unresolved.
};

/// Stand-in value factories for each candidate tag.
///
/// For [_CandidateTag.mapStringDynamic] the stand-in is produced by
/// [_TDummyProbingMap] itself (a child probing map), so this table returns
/// `null` as a placeholder — the map overrides this path explicitly.
dynamic _standInForTag(_CandidateTag tag) => switch (tag) {
  _CandidateTag.string => '',
  _CandidateTag.int_ => 0,
  _CandidateTag.double_ => 0.0,
  _CandidateTag.num_ => 0,
  _CandidateTag.bool_ => false,
  _CandidateTag.dateTime => DateTime.utc(1970),
  _CandidateTag.timestamp => Timestamp.fromDate(DateTime.utc(1970)),
  _CandidateTag.listDynamic => const <dynamic>[],
  _CandidateTag.mapStringDynamic => null, // handled by operator[]
  _CandidateTag.geoPoint => const GeoPoint(0, 0),
  _CandidateTag.documentReference => null,
  _CandidateTag.blob => Blob(Uint8List(0)),
  _CandidateTag.null_ => null,
};

// ---------------------------------------------------------------------------
// Candidate cursor
// ---------------------------------------------------------------------------

/// Tracks the current candidate index for a single field during probing.
class _CandidateCursor {
  int index = 0;

  _CandidateTag get current => _CandidateTag.values[index];

  bool get isExhausted => index >= _CandidateTag.values.length;

  /// Advances to the next candidate. Returns `true` if a valid candidate
  /// remains, `false` if exhausted.
  bool advance() {
    index++;
    return !isExhausted;
  }
}

// ---------------------------------------------------------------------------
// Resolved value wrapper
// ---------------------------------------------------------------------------

/// Internal tagging for a resolved probe result — either a flat type or a
/// nested child probing map.
sealed class _ResolvedProbeValue {
  const _ResolvedProbeValue();
}

final class _ResolvedLeaf extends _ResolvedProbeValue {
  const _ResolvedLeaf(this.type);
  final Type type;
}

final class _ResolvedBranch extends _ResolvedProbeValue {
  const _ResolvedBranch(this.child);
  final _TDummyProbingMap child;
}

// NOTE: DocumentReference is sealed in cloud_firestore, so no stand-in can
// be constructed. The candidate returns null, causing non-nullable
// DocumentReference casts to fail and widen. Fields expecting
// DocumentReference will land in `unresolved`, which is correct — the
// registry's placeholder system handles them downstream.

// ---------------------------------------------------------------------------
// Probing map
// ---------------------------------------------------------------------------

/// A library-private [Map<String, dynamic>] implementation that discovers a
/// DTO's field schema by intercepting `json['field'] as SomeType` calls inside
/// a caller's `fromJson`.
///
/// Consumers never interact with this class directly — they call
/// [_TDummyProbingMap.probe] which runs the widen-and-replay loop and returns
/// a [TDummySchema].
class _TDummyProbingMap extends MapBase<String, dynamic> {
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// Resolved probe values keyed by field name (insertion-ordered).
  final Map<String, _ResolvedProbeValue> _resolved = {};

  /// Candidate cursors keyed by field name.
  final Map<String, _CandidateCursor> _cursors = {};

  /// Field names whose candidate list was fully exhausted.
  final Set<String> _unresolved = {};

  /// The last field name accessed via [operator[]].
  String? _lastKey;

  /// Cached child probing maps keyed by field name. Reused across replays so
  /// nested cursor state is preserved.
  final Map<String, _TDummyProbingMap> _childMaps = {};

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Maximum number of DTO fields the probe loop accounts for.
  static const int _maxFields = 64;

  /// Total candidate count (including the terminal null).
  static final int _candidateCount = _CandidateTag.values.length;

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Discovers the field schema of a DTO by replaying its [fromJson] against
  /// a probing map, widening failing fields through the candidate list until
  /// the function completes or the attempt bound is exhausted.
  static TDummySchema probe<T>(
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final root = _TDummyProbingMap();
    final maxAttempts = _candidateCount * _maxFields;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        fromJson(root);
        // fromJson completed — schema is resolved.
        break;
      } catch (_) {
        // If no field was ever accessed, the error is unrelated to probing.
        if (!root._hasAnyAccess()) rethrow;

        // Widen the deepest active field.
        final widened = root._widenDeepest();
        if (!widened) break; // Nothing left to widen.
      }
    }

    return root._buildSchema();
  }

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  /// Whether any field on this map (or any nested child) has been accessed.
  bool _hasAnyAccess() {
    if (_lastKey != null) return true;
    return _childMaps.values.any((child) => child._hasAnyAccess());
  }

  /// Attempts to widen the deepest active field in the probing tree.
  ///
  /// Recurses into child probing maps before widening the current level.
  /// Returns `true` if a field was successfully widened, `false` if all
  /// candidates are exhausted everywhere.
  bool _widenDeepest() {
    final key = _lastKey;
    if (key == null) return false;

    // If the resolved value for this key is a child probing map, try widening
    // inside the child first.
    final resolved = _resolved[key];
    if (resolved is _ResolvedBranch) {
      if (resolved.child._widenDeepest()) return true;
    }

    // Widen this field's own cursor.
    final cursor = _cursors[key];
    if (cursor == null || cursor.isExhausted) return false;

    if (cursor.advance()) {
      // Clear any cached child map if we're moving past the map candidate.
      _childMaps.remove(key);
      return true;
    }

    // Cursor exhausted — mark unresolved.
    _unresolved.add(key);
    _resolved.remove(key);
    return false;
  }

  /// Converts the internal probe state into a [TDummySchema].
  TDummySchema _buildSchema() {
    final fields = <String, TDummySchemaField>{};

    for (final entry in _resolved.entries) {
      final value = entry.value;
      switch (value) {
        case _ResolvedLeaf(:final type):
          fields[entry.key] = TDummySchemaLeaf(type);
        case _ResolvedBranch(:final child):
          // If the child observed nested field accesses, emit a branch.
          // Otherwise treat it as a raw Map<String, dynamic> leaf.
          if (child._resolved.isNotEmpty || child._unresolved.isNotEmpty) {
            fields[entry.key] = TDummySchemaBranch(child._buildSchema());
          } else {
            fields[entry.key] = const TDummySchemaLeaf(Map<String, dynamic>);
          }
      }
    }

    return TDummySchema(
      fields: fields,
      unresolved: Set<String>.of(_unresolved),
    );
  }

  // ⚡️ MAP OVERRIDES (read-only probing contract) -------------------------------------------- \\

  @override
  dynamic operator [](Object? key) {
    if (key is! String) return null;

    _lastKey = key;

    // Ensure a cursor exists for this key.
    final cursor = _cursors.putIfAbsent(key, _CandidateCursor.new);

    if (cursor.isExhausted) {
      _unresolved.add(key);
      return null;
    }

    final tag = cursor.current;

    // Special handling: Map<String, dynamic> candidate returns a cached child
    // probing map for recursive nested DTO discovery.
    if (tag == _CandidateTag.mapStringDynamic) {
      final child = _childMaps.putIfAbsent(key, _TDummyProbingMap.new);
      _resolved[key] = _ResolvedBranch(child);
      return child;
    }

    // Special handling: null candidate — if we reach here the field is
    // effectively unresolved (only null satisfies).
    if (tag == _CandidateTag.null_) {
      // Don't record a leaf for null — let it remain for widening to exhaust.
      return null;
    }

    // Flat candidate.
    _resolved[key] = _ResolvedLeaf(_candidateLeafTypes[tag]!);
    return _standInForTag(tag);
  }

  @override
  void operator []=(String key, dynamic value) {
    throw UnsupportedError(
      'Probing map is read-only during schema discovery.',
    );
  }

  @override
  dynamic remove(Object? key) {
    throw UnsupportedError(
      'Probing map is read-only during schema discovery.',
    );
  }

  @override
  void clear() {
    throw UnsupportedError(
      'Probing map is read-only during schema discovery.',
    );
  }

  @override
  bool containsKey(Object? key) => true;

  @override
  Iterable<String> get keys => _resolved.keys;
}
