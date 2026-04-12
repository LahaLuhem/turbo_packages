// ignore_for_file: subtype_of_sealed_class

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/constants/t_error_codes.dart';
import 'package:turbo_firestore_api/enums/t_operation_type.dart';
import 'package:turbo_firestore_api/enums/t_search_term_type.dart';
import 'package:turbo_firestore_api/enums/t_timestamp_type.dart';
import 'package:turbo_firestore_api/exceptions/t_firestore_exception.dart';
import 'package:turbo_firestore_api/generators/t_dummy_schema.dart';
import 'package:turbo_firestore_api/generators/t_value_generator.dart';
import 'package:turbo_firestore_api/generators/t_value_generator_registry.dart';
import 'package:turbo_firestore_api/models/t_write_batch_with_reference.dart';
import 'package:turbo_firestore_api/typedefs/collection_reference_def.dart';
import 'package:turbo_firestore_api/util/t_firestore_logger.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';

part '_t_dummy_probing_map.dart';

// ---------------------------------------------------------------------------
// Test-only entry points
// ---------------------------------------------------------------------------

/// Test-only entry point for the library-private [_TDummyProbingMap].
///
/// Forwards to [_TDummyProbingMap.probe] so unit tests can exercise the
/// probing engine without exposing the private class.
@visibleForTesting
TDummySchema probeDummySchemaForTesting<T>(
  T Function(Map<String, dynamic>) fromJson,
) =>
    _TDummyProbingMap.probe<T>(fromJson);

/// Returns the probed schema from a [TDummyFirestoreApi] instance.
@visibleForTesting
TDummySchema dummySchemaForTesting<T>(TDummyFirestoreApi<T> api) =>
    api._schema;

/// Returns the value generator registry from a [TDummyFirestoreApi] instance.
@visibleForTesting
TValueGeneratorRegistry dummyRegistryForTesting<T>(
  TDummyFirestoreApi<T> api,
) =>
    api._registry;

/// Generates a deterministic dummy id from a [TDummyFirestoreApi] instance.
@visibleForTesting
String genDummyIdForTesting<T>(TDummyFirestoreApi<T> api) =>
    api._genDummyId();

/// Awaits the latency gate of a [TDummyFirestoreApi] instance.
@visibleForTesting
Future<void> applyDummyLatencyForTesting<T>(
  TDummyFirestoreApi<T> api,
) =>
    api._applyLatency();

/// Rolls a simulated failure exception from a [TDummyFirestoreApi] instance.
@visibleForTesting
TFirestoreException? rollDummyFailureExceptionForTesting<T>(
  TDummyFirestoreApi<T> api, {
  required TOperationType operationType,
  String? id,
  Map<String, dynamic>? documentData,
}) =>
    api._rollFailureException(
      operationType: operationType,
      id: id,
      documentData: documentData,
    );

/// Registers a collection stream controller for testing dispose behavior.
@visibleForTesting
void addCollectionControllerForTesting<T>(
  TDummyFirestoreApi<T> api,
  StreamController<List<T>> controller,
) =>
    api._collectionControllers.add(controller);

/// Registers a document stream controller for testing dispose behavior.
@visibleForTesting
void addDocControllerForTesting<T>(
  TDummyFirestoreApi<T> api,
  String id,
  StreamController<T?> controller,
) =>
    (api._docControllers[id] ??= {}).add(controller);

/// Exposes the query filter/sort seam for testing.
@visibleForTesting
List<Map<String, dynamic>> applyDummyQueryFilterAndSortForTesting<T>(
  TDummyFirestoreApi<T> api, {
  required String? whereDescription,
  required List<Map<String, dynamic>> input,
}) =>
    api._applyQueryFilterAndSort(
      whereDescription: whereDescription,
      input: input,
    );

/// Returns the raw in-memory store for testing.
@visibleForTesting
Map<String, Map<String, dynamic>> dummyStoreForTesting<T>(
  TDummyFirestoreApi<T> api,
) =>
    api._store;

/// Returns the number of active typed collection stream controllers.
@visibleForTesting
int collectionControllerCountForTesting<T>(TDummyFirestoreApi<T> api) =>
    api._collectionControllers.length;

/// Returns the number of active raw collection stream controllers.
@visibleForTesting
int rawCollectionControllerCountForTesting<T>(TDummyFirestoreApi<T> api) =>
    api._rawCollectionControllers.length;

/// Returns the number of active document stream controllers for [id].
@visibleForTesting
int docControllerCountForTesting<T>(TDummyFirestoreApi<T> api, String id) =>
    api._docControllers[id]?.length ?? 0;

/// Returns the default collection size for testing.
@visibleForTesting
int dummyDefaultCollectionSizeForTesting<T>(TDummyFirestoreApi<T> api) =>
    api._defaultCollectionSize;

/// Returns the path snapshot for testing.
@visibleForTesting
String dummyPathSnapshotForTesting<T>(TDummyFirestoreApi<T> api) =>
    api._pathSnapshot;

/// Returns the query filters for testing.
@visibleForTesting
Map<String, bool Function(Map<String, dynamic>)>
    dummyQueryFiltersForTesting<T>(TDummyFirestoreApi<T> api) =>
        api._queryFilters;

/// Returns the query sort comparators for testing.
@visibleForTesting
Map<String, int Function(Map<String, dynamic>, Map<String, dynamic>)>
    dummyQuerySortForTesting<T>(TDummyFirestoreApi<T> api) => api._querySort;

/// Generates a raw JSON map for a document with the given [id].
@visibleForTesting
Map<String, dynamic> generateDocJsonForTesting<T>(
  TDummyFirestoreApi<T> api, {
  required String id,
}) =>
    api._generateDocJson(id: id);

/// Applies timestamps to a raw JSON map.
@visibleForTesting
Map<String, dynamic> applyTimestampsForTesting<T>(
  TDummyFirestoreApi<T> api, {
  required Map<String, dynamic> json,
  required TTimestampType type,
}) =>
    api._applyTimestamps(json: json, type: type);

/// Re-emits the full store snapshot to every open collection controller.
@visibleForTesting
void emitCollectionsForTesting<T>(TDummyFirestoreApi<T> api) =>
    api._emitCollections();

/// Re-emits a single document to every open controller for the given [id].
@visibleForTesting
void emitDocForTesting<T>(TDummyFirestoreApi<T> api, String id, T? entity) =>
    api._emitDoc(id, entity);

// ---------------------------------------------------------------------------
// TDummyFirestoreApi
// ---------------------------------------------------------------------------

/// A drop-in replacement for [TFirestoreApi] that serves realistic fake data
/// from an in-memory store without contacting Firestore.
///
/// Consumers swap their real API for this variant at DI wire-up time — no
/// service, view model, or UI change required. The dummy discovers the
/// entity's field types by probing the caller's [fromJson], then uses a
/// [TValueGeneratorRegistry] to produce realistic values for each field.
///
/// This class delivers the skeleton: constructor, init pipeline, internal
/// helpers, and dispose. Read/write/stream overrides land in subsequent tasks.
class TDummyFirestoreApi<T> extends TFirestoreApi<T> {
  /// Creates a dummy API that produces realistic fake data in memory.
  ///
  /// Accepts the same parameters as [TFirestoreApi] plus dummy-only
  /// configuration for generators, collection size, latency, failure
  /// injection, and query filtering.
  ///
  /// [fromJson] must be non-null — the probe pass and every generator pipe
  /// entities through it.
  factory TDummyFirestoreApi({
    required FirebaseFirestore firebaseFirestore,
    required String Function() collectionPath,
    Map<String, dynamic> Function(T value)? toJson,
    T Function(Map<String, dynamic> json)? fromJson,
    T Function(Map<String, dynamic> json)? fromJsonError,
    bool tryAddLocalId = false,
    TFirestoreLogger? logger,
    String createdAtFieldName = 'createdAt',
    String updatedAtFieldName = 'updatedAt',
    String idFieldName = 'id',
    String documentReferenceFieldName = 'documentReference',
    bool isCollectionGroup = false,
    bool tryAddLocalDocumentReference = false,
    GetOptions? getOptions,
    // Dummy-only parameters
    Map<String, TValueGenerator>? fieldGenerators,
    Map<Type, TValueGenerator>? typeGenerators,
    int defaultCollectionSize = 20,
    Duration dummyDelayDuration = const Duration(milliseconds: 225),
    List<Duration>? dummyDelayRange,
    double randomFailurePercentage = 0,
    int? seed,
    Map<String, bool Function(Map<String, dynamic> doc)>? queryFilters,
    Map<String, int Function(Map<String, dynamic> a, Map<String, dynamic> b)>?
        querySort,
  }) {
    assert(
      fromJson != null,
      'TDummyFirestoreApi requires a non-null fromJson to probe the entity '
      'schema and materialise documents.',
    );
    if (randomFailurePercentage < 0 || randomFailurePercentage > 100) {
      throw ArgumentError.value(
        randomFailurePercentage,
        'randomFailurePercentage',
        'Must be between 0 and 100',
      );
    }
    if (defaultCollectionSize < 0) {
      throw ArgumentError.value(
        defaultCollectionSize,
        'defaultCollectionSize',
        'Must be >= 0',
      );
    }
    if (dummyDelayRange != null) {
      if (dummyDelayRange.length != 2) {
        throw ArgumentError.value(
          dummyDelayRange,
          'dummyDelayRange',
          'Must contain exactly 2 durations [min, max]',
        );
      }
      if (dummyDelayRange[0].isNegative || dummyDelayRange[1].isNegative) {
        throw ArgumentError.value(
          dummyDelayRange,
          'dummyDelayRange',
          'Durations must be non-negative',
        );
      }
      if (dummyDelayRange[1] < dummyDelayRange[0]) {
        throw ArgumentError.value(
          dummyDelayRange,
          'dummyDelayRange',
          'max duration must be >= min duration',
        );
      }
    }

    final pathSnapshot = collectionPath();
    final rng = Random(seed ?? pathSnapshot.hashCode);
    final fromJsonRequired = fromJson!;
    final schema = _TDummyProbingMap.probe<T>(fromJsonRequired);
    final registry = TValueGeneratorRegistry.build(
      fieldGenerators: fieldGenerators,
      typeGenerators: typeGenerators,
      schema: schema,
      random: rng,
    );

    return TDummyFirestoreApi._(
      firebaseFirestore: firebaseFirestore,
      collectionPath: collectionPath,
      toJson: toJson,
      fromJson: fromJson,
      fromJsonError: fromJsonError,
      tryAddLocalId: tryAddLocalId,
      logger: logger,
      createdAtFieldName: createdAtFieldName,
      updatedAtFieldName: updatedAtFieldName,
      idFieldName: idFieldName,
      documentReferenceFieldName: documentReferenceFieldName,
      isCollectionGroup: isCollectionGroup,
      tryAddLocalDocumentReference: tryAddLocalDocumentReference,
      getOptions: getOptions,
      fromJsonRequired: fromJsonRequired,
      dummyCreatedAtFieldName: createdAtFieldName,
      dummyUpdatedAtFieldName: updatedAtFieldName,
      dummyIdFieldName: idFieldName,
      defaultCollectionSize: defaultCollectionSize,
      dummyDelayDuration: dummyDelayDuration,
      dummyDelayRange: dummyDelayRange != null
          ? List<Duration>.unmodifiable(dummyDelayRange)
          : null,
      randomFailurePercentage: randomFailurePercentage,
      queryFilters: Map<String, bool Function(Map<String, dynamic>)>.of(
        queryFilters ?? const {},
      ),
      querySort: Map<String,
          int Function(Map<String, dynamic>, Map<String, dynamic>)>.of(
        querySort ?? const {},
      ),
      pathSnapshot: pathSnapshot,
      rng: rng,
      schema: schema,
      registry: registry,
      firebaseFirestoreSnapshot: firebaseFirestore,
      isCollectionGroupSnapshot: isCollectionGroup,
    );
  }

  TDummyFirestoreApi._({
    required FirebaseFirestore firebaseFirestore,
    required String Function() collectionPath,
    Map<String, dynamic> Function(T value)? toJson,
    T Function(Map<String, dynamic> json)? fromJson,
    T Function(Map<String, dynamic> json)? fromJsonError,
    bool tryAddLocalId = false,
    TFirestoreLogger? logger,
    String createdAtFieldName = 'createdAt',
    String updatedAtFieldName = 'updatedAt',
    String idFieldName = 'id',
    String documentReferenceFieldName = 'documentReference',
    bool isCollectionGroup = false,
    bool tryAddLocalDocumentReference = false,
    GetOptions? getOptions,
    // Computed dummy state
    required T Function(Map<String, dynamic>) fromJsonRequired,
    required String dummyCreatedAtFieldName,
    required String dummyUpdatedAtFieldName,
    required String dummyIdFieldName,
    required int defaultCollectionSize,
    required Duration dummyDelayDuration,
    required List<Duration>? dummyDelayRange,
    required double randomFailurePercentage,
    required Map<String, bool Function(Map<String, dynamic>)> queryFilters,
    required Map<String,
            int Function(Map<String, dynamic>, Map<String, dynamic>)>
        querySort,
    required String pathSnapshot,
    required Random rng,
    required TDummySchema schema,
    required TValueGeneratorRegistry registry,
    required FirebaseFirestore firebaseFirestoreSnapshot,
    required bool isCollectionGroupSnapshot,
  })  : _firebaseFirestoreSnapshot = firebaseFirestoreSnapshot,
        _fromJsonRequired = fromJsonRequired,
        _isCollectionGroupSnapshot = isCollectionGroupSnapshot,
        _createdAtFieldName = dummyCreatedAtFieldName,
        _updatedAtFieldName = dummyUpdatedAtFieldName,
        _idFieldName = dummyIdFieldName,
        _defaultCollectionSize = defaultCollectionSize,
        _dummyDelayDuration = dummyDelayDuration,
        _dummyDelayRange = dummyDelayRange,
        _randomFailurePercentage = randomFailurePercentage,
        _queryFilters = queryFilters,
        _querySort = querySort,
        _pathSnapshot = pathSnapshot,
        _rng = rng,
        _schema = schema,
        _registry = registry,
        _store = {},
        _collectionControllers = {},
        _collectionControllerWhereDescriptions = {},
        _rawCollectionControllers = {},
        _rawCollectionControllerWhereDescriptions = {},
        _docControllers = {},
        _nextDummyId = 0,
        super(
          firebaseFirestore: firebaseFirestore,
          collectionPath: collectionPath,
          toJson: toJson,
          fromJson: fromJson,
          fromJsonError: fromJsonError,
          tryAddLocalId: tryAddLocalId,
          logger: logger,
          createdAtFieldName: createdAtFieldName,
          updatedAtFieldName: updatedAtFieldName,
          idFieldName: idFieldName,
          documentReferenceFieldName: documentReferenceFieldName,
          isCollectionGroup: isCollectionGroup,
          tryAddLocalDocumentReference: tryAddLocalDocumentReference,
          getOptions: getOptions,
        );

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  /// The [FirebaseFirestore] instance captured for use by
  /// [_TDummyDocumentReference] placeholders.
  final FirebaseFirestore _firebaseFirestoreSnapshot;

  /// The caller's non-null [fromJson] captured for probing and materialisation.
  final T Function(Map<String, dynamic>) _fromJsonRequired;

  /// The createdAt field name for timestamp application.
  final String _createdAtFieldName;

  /// The updatedAt field name for timestamp application.
  final String _updatedAtFieldName;

  /// The id field name for injecting document ids into generated JSON.
  final String _idFieldName;

  /// Whether the API was constructed for a collection group.
  final bool _isCollectionGroupSnapshot;

  /// Number of entities to generate when the store is first seeded.
  final int _defaultCollectionSize;

  /// Fixed latency per call when [_dummyDelayRange] is null.
  final Duration _dummyDelayDuration;

  /// When set, the delay is a uniform-random duration inside [min, max].
  final List<Duration>? _dummyDelayRange;

  /// Percentage chance (0..100) a call returns a simulated failure.
  final double _randomFailurePercentage;

  /// Named filter predicates keyed by whereDescription.
  final Map<String, bool Function(Map<String, dynamic>)> _queryFilters;

  /// Optional comparators keyed by whereDescription.
  final Map<String, int Function(Map<String, dynamic>, Map<String, dynamic>)>
      _querySort;

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// The probed schema describing the entity's field names and types.
  final TDummySchema _schema;

  /// The merged value generator registry.
  final TValueGeneratorRegistry _registry;

  /// In-memory store of raw JSON maps keyed by document id.
  final Map<String, Map<String, dynamic>> _store;

  /// Open typed collection stream controllers.
  final Set<StreamController<List<T>>> _collectionControllers;

  /// Per-controller whereDescription for typed collection streams.
  ///
  /// A `null` value means the stream is unfiltered (streamAllWithConverter).
  final Map<StreamController<List<T>>, String?>
      _collectionControllerWhereDescriptions;

  /// Open raw collection stream controllers (for streamByQuery).
  final Set<StreamController<List<Map<String, dynamic>>>>
      _rawCollectionControllers;

  /// Per-controller whereDescription for raw collection streams.
  final Map<StreamController<List<Map<String, dynamic>>>, String>
      _rawCollectionControllerWhereDescriptions;

  /// Open document stream controllers keyed by document id.
  final Map<String, Set<StreamController<T?>>> _docControllers;

  /// Seeded random number generator for deterministic output.
  final Random _rng;

  /// The collection path captured once at construction time.
  final String _pathSnapshot;

  /// Monotonic counter for deterministic id generation.
  int _nextDummyId;

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Waits the configured latency before returning.
  ///
  /// Uses [_dummyDelayDuration] for fixed delay, or samples uniformly inside
  /// [_dummyDelayRange] when set.
  Future<void> _applyLatency() {
    final range = _dummyDelayRange;
    if (range != null) {
      final minUs = range[0].inMicroseconds;
      final maxUs = range[1].inMicroseconds;
      final spanUs = maxUs - minUs;
      final sampledUs = spanUs > 0 ? minUs + _rng.nextInt(spanUs + 1) : minUs;
      return Future<void>.delayed(Duration(microseconds: sampledUs));
    }
    return Future<void>.delayed(_dummyDelayDuration);
  }

  /// Rolls against [_randomFailurePercentage] and returns a simulated
  /// [TFirestoreException] when the roll trips, or `null` on pass.
  TFirestoreException? _rollFailureException({
    required TOperationType operationType,
    String? id,
    Map<String, dynamic>? documentData,
  }) {
    if (_randomFailurePercentage <= 0) return null;
    final roll = _rng.nextDouble() * 100;
    if (roll >= _randomFailurePercentage) return null;

    // Pick one of the 6 failure subtypes uniformly.
    final subtypeIndex = _rng.nextInt(6);
    final syntheticStackTrace = StackTrace.current;

    switch (subtypeIndex) {
      case 0:
        return TurboFirestorePermissionDeniedException(
          message: '[Dummy] ${TErrorCodes.permissionDeniedMessage}',
          path: _pathSnapshot,
          id: id,
          operationType: operationType,
          documentData: documentData,
          stackTrace: syntheticStackTrace,
          originalException: FirebaseException(
            plugin: 'cloud_firestore',
            code: TErrorCodes.permissionDenied,
            message: TErrorCodes.permissionDeniedMessage,
          ),
        );
      case 1:
        return TurboFirestoreUnavailableException(
          message: '[Dummy] ${TErrorCodes.unavailableMessage}',
          path: _pathSnapshot,
          id: id,
          operationType: operationType,
          documentData: documentData,
          stackTrace: syntheticStackTrace,
          originalException: FirebaseException(
            plugin: 'cloud_firestore',
            code: TErrorCodes.unavailable,
            message: TErrorCodes.unavailableMessage,
          ),
        );
      case 2:
        return TurboFirestoreNotFoundException(
          message: '[Dummy] ${TErrorCodes.notFoundMessage}',
          path: _pathSnapshot,
          id: id,
          operationType: operationType,
          documentData: documentData,
          stackTrace: syntheticStackTrace,
          originalException: FirebaseException(
            plugin: 'cloud_firestore',
            code: TErrorCodes.notFound,
            message: TErrorCodes.notFoundMessage,
          ),
        );
      case 3:
        return TurboFirestoreDeadlineExceededException(
          message: '[Dummy] ${TErrorCodes.deadlineExceededMessage}',
          path: _pathSnapshot,
          id: id,
          operationType: operationType,
          documentData: documentData,
          stackTrace: syntheticStackTrace,
          originalException: FirebaseException(
            plugin: 'cloud_firestore',
            code: TErrorCodes.deadlineExceeded,
            message: TErrorCodes.deadlineExceededMessage,
          ),
        );
      case 4:
        return TurboFirestoreCancelledException(
          message: '[Dummy] ${TErrorCodes.cancelledMessage}',
          path: _pathSnapshot,
          id: id,
          operationType: operationType,
          documentData: documentData,
          stackTrace: syntheticStackTrace,
          originalException: FirebaseException(
            plugin: 'cloud_firestore',
            code: TErrorCodes.cancelled,
            message: TErrorCodes.cancelledMessage,
          ),
        );
      default:
        return TurboFirestoreGenericException(
          message: '[Dummy] ${TErrorCodes.unknownMessage}',
          code: TErrorCodes.unknown,
          path: _pathSnapshot,
          id: id,
          operationType: operationType,
          documentData: documentData,
          stackTrace: syntheticStackTrace,
          originalException: FirebaseException(
            plugin: 'cloud_firestore',
            code: TErrorCodes.unknown,
            message: TErrorCodes.unknownMessage,
          ),
        );
    }
  }

  /// Returns a deterministic id of the shape `dummy_<pathSnapshot>_<index>`.
  String _genDummyId() => 'dummy_${_pathSnapshot}_${_nextDummyId++}';

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  @override
  Future<TurboResponse<T>> getByIdWithConverter({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroupSnapshot == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating '
      'with a collection group, therefore, you must specify the '
      'collectionPathOverride containing all parent collection and document '
      'ids in order to make this method work.',
    );
    try {
      await _applyLatency();
      final failure = _rollFailureException(
        operationType: TOperationType.read,
        id: id,
      );
      if (failure != null) return TurboResponse.fail(error: failure);
      final stored = _getOrCreateStoredDoc(id);
      return TurboResponse.success(result: _materialise(stored));
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<Map<String, dynamic>>> getById({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroupSnapshot == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating '
      'with a collection group, therefore, you must specify the '
      'collectionPathOverride containing all parent collection and document '
      'ids in order to make this method work.',
    );
    try {
      await _applyLatency();
      final failure = _rollFailureException(
        operationType: TOperationType.read,
        id: id,
      );
      if (failure != null) return TurboResponse.fail(error: failure);
      final stored = _getOrCreateStoredDoc(id);
      return TurboResponse.success(result: _copyRawDoc(stored));
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<List<T>>> listAllWithConverter() async {
    try {
      await _applyLatency();
      final failure = _rollFailureException(
        operationType: TOperationType.read,
      );
      if (failure != null) return TurboResponse.fail(error: failure);
      _seedStoreIfNeeded();
      return TurboResponse.success(
        result: _store.values.map(_materialise).toList(growable: false),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<List<Map<String, dynamic>>>> listAll() async {
    try {
      await _applyLatency();
      final failure = _rollFailureException(
        operationType: TOperationType.read,
      );
      if (failure != null) return TurboResponse.fail(error: failure);
      _seedStoreIfNeeded();
      return TurboResponse.success(result: _rawStoreSnapshot());
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<List<T>>> listByQueryWithConverter({
    required CollectionReferenceDef<T> collectionReferenceQuery,
    required String whereDescription,
  }) async {
    try {
      await _applyLatency();
      final failure = _rollFailureException(
        operationType: TOperationType.read,
      );
      if (failure != null) return TurboResponse.fail(error: failure);
      _seedStoreIfNeeded();
      final filtered = _applyQueryFilterAndSort(
        whereDescription: whereDescription,
        input: _rawStoreSnapshot(),
      );
      return TurboResponse.success(
        result: filtered.map(_materialise).toList(growable: false),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<List<Map<String, dynamic>>>> listByQuery({
    required CollectionReferenceDef<Map<String, dynamic>>
        collectionReferenceQuery,
    required String whereDescription,
  }) async {
    try {
      await _applyLatency();
      final failure = _rollFailureException(
        operationType: TOperationType.read,
      );
      if (failure != null) return TurboResponse.fail(error: failure);
      _seedStoreIfNeeded();
      return TurboResponse.success(
        result: _applyQueryFilterAndSort(
          whereDescription: whereDescription,
          input: _rawStoreSnapshot(),
        ),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<List<T>>> listBySearchTermWithConverter({
    required String searchTerm,
    required String searchField,
    required TSearchTermType searchTermType,
    bool doSearchNumberEquivalent = false,
    int? limit,
  }) async {
    try {
      await _applyLatency();
      final failure = _rollFailureException(
        operationType: TOperationType.read,
      );
      if (failure != null) return TurboResponse.fail(error: failure);
      _seedStoreIfNeeded();
      final filtered = _applyQueryFilterAndSort(
        whereDescription: null,
        input: _rawStoreSnapshot(),
      );
      return TurboResponse.success(
        result: filtered.map(_materialise).toList(growable: false),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<List<Map<String, dynamic>>>> listBySearchTerm({
    required String searchTerm,
    required String searchField,
    required TSearchTermType searchTermType,
    bool doSearchNumberEquivalent = false,
    int? limit,
  }) async {
    try {
      await _applyLatency();
      final failure = _rollFailureException(
        operationType: TOperationType.read,
      );
      if (failure != null) return TurboResponse.fail(error: failure);
      _seedStoreIfNeeded();
      return TurboResponse.success(
        result: _applyQueryFilterAndSort(
          whereDescription: null,
          input: _rawStoreSnapshot(),
        ),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<bool> docExists({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroupSnapshot == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating '
      'with a collection group, therefore, you must specify the '
      'collectionPathOverride containing all parent collection and document '
      'ids in order to make this method work.',
    );
    await _applyLatency();
    final failure = _rollFailureException(
      operationType: TOperationType.read,
      id: id,
    );
    if (failure != null) throw failure;
    return _store.containsKey(id);
  }

  // -- Stream overrides --------------------------------------------------- \\

  /// Guidance message for raw Firestore snapshot streams that cannot be
  /// constructed in dummy mode.
  static const _dummyStreamGuidance =
      'TDummyFirestoreApi cannot construct Firestore snapshot objects in '
      'dummy mode. Use the WithConverter variant instead '
      '(e.g. streamAllWithConverter / streamDocByIdWithConverter).';

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAll() =>
      throw UnimplementedError(_dummyStreamGuidance);

  @override
  Stream<List<T>> streamAllWithConverter() {
    final controller = StreamController<List<T>>.broadcast();
    controller.onListen = () {
      _collectionControllers.add(controller);
      _collectionControllerWhereDescriptions[controller] = null;
      Future.microtask(() async {
        await _applyLatency();
        if (!_collectionControllers.contains(controller)) return;
        final failure = _rollFailureException(
          operationType: TOperationType.stream,
        );
        if (failure != null) {
          if (!controller.isClosed) controller.addError(failure);
          return;
        }
        _seedStoreIfNeeded();
        final snapshot = _applyQueryFilterAndSort(
          whereDescription: null,
          input: _rawStoreSnapshot(),
        );
        if (!controller.isClosed) {
          controller.add(
            snapshot.map(_materialise).toList(growable: false),
          );
        }
      });
    };
    controller.onCancel = () {
      _collectionControllers.remove(controller);
      _collectionControllerWhereDescriptions.remove(controller);
    };
    return controller.stream;
  }

  @override
  Stream<List<T>> streamByQueryWithConverter({
    CollectionReferenceDef<T>? collectionReferenceQuery,
    required String whereDescription,
  }) {
    final controller = StreamController<List<T>>.broadcast();
    controller.onListen = () {
      _collectionControllers.add(controller);
      _collectionControllerWhereDescriptions[controller] = whereDescription;
      Future.microtask(() async {
        await _applyLatency();
        if (!_collectionControllers.contains(controller)) return;
        final failure = _rollFailureException(
          operationType: TOperationType.stream,
        );
        if (failure != null) {
          if (!controller.isClosed) controller.addError(failure);
          return;
        }
        _seedStoreIfNeeded();
        final snapshot = _applyQueryFilterAndSort(
          whereDescription: whereDescription,
          input: _rawStoreSnapshot(),
        );
        if (!controller.isClosed) {
          controller.add(
            snapshot.map(_materialise).toList(growable: false),
          );
        }
      });
    };
    controller.onCancel = () {
      _collectionControllers.remove(controller);
      _collectionControllerWhereDescriptions.remove(controller);
    };
    return controller.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> streamByQuery({
    required CollectionReferenceDef<Map<String, dynamic>>?
        collectionReferenceQuery,
    required String whereDescription,
  }) {
    final controller =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    controller.onListen = () {
      _rawCollectionControllers.add(controller);
      _rawCollectionControllerWhereDescriptions[controller] = whereDescription;
      Future.microtask(() async {
        await _applyLatency();
        if (!_rawCollectionControllers.contains(controller)) return;
        final failure = _rollFailureException(
          operationType: TOperationType.stream,
        );
        if (failure != null) {
          if (!controller.isClosed) controller.addError(failure);
          return;
        }
        _seedStoreIfNeeded();
        final snapshot = _applyQueryFilterAndSort(
          whereDescription: whereDescription,
          input: _rawStoreSnapshot(),
        );
        if (!controller.isClosed) controller.add(snapshot);
      });
    };
    controller.onCancel = () {
      _rawCollectionControllers.remove(controller);
      _rawCollectionControllerWhereDescriptions.remove(controller);
    };
    return controller.stream;
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamByDocId({
    required String id,
    String? collectionPathOverride,
  }) =>
      throw UnimplementedError(_dummyStreamGuidance);

  @override
  Stream<T?> streamDocByIdWithConverter({
    required String id,
    String? collectionPathOverride,
  }) {
    assert(
      _isCollectionGroupSnapshot == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating '
      'with a collection group, therefore, you must specify the '
      'collectionPathOverride containing all parent collection and document '
      'ids in order to make this method work.',
    );
    final controller = StreamController<T?>.broadcast();
    controller.onListen = () {
      (_docControllers[id] ??= {}).add(controller);
      Future.microtask(() async {
        await _applyLatency();
        final controllers = _docControllers[id];
        if (controllers == null || !controllers.contains(controller)) return;
        final failure = _rollFailureException(
          operationType: TOperationType.stream,
          id: id,
        );
        if (failure != null) {
          if (!controller.isClosed) controller.addError(failure);
          return;
        }
        final stored = _getOrCreateStoredDoc(id);
        if (!controller.isClosed) controller.add(_materialise(stored));
      });
    };
    controller.onCancel = () {
      final controllers = _docControllers[id];
      if (controllers != null) {
        controllers.remove(controller);
        if (controllers.isEmpty) _docControllers.remove(id);
      }
    };
    return controller.stream;
  }

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  /// Returns the stored JSON map for [id], generating and caching it if absent.
  ///
  /// Does NOT apply timestamps — reads never write timestamps.
  Map<String, dynamic> _getOrCreateStoredDoc(String id) {
    final existing = _store[id];
    if (existing != null) return existing;
    final json = _generateDocJson(id: id);
    _store[id] = json;
    return json;
  }

  /// Seeds the store with [_defaultCollectionSize] documents if it is empty.
  ///
  /// Each seeded document gets a createdAt timestamp spread across trailing
  /// days: entity at index `i` receives `now - i days`. The updatedAt
  /// timestamp matches createdAt for seeded documents.
  void _seedStoreIfNeeded() {
    if (_store.isNotEmpty) return;
    final now = DateTime.now();
    for (var i = 0; i < _defaultCollectionSize; i++) {
      final id = _genDummyId();
      final json = _generateDocJson(id: id);
      final seedDate = now.subtract(Duration(days: i));
      final seedTimestamp = Timestamp.fromDate(seedDate);
      json[_createdAtFieldName] = seedTimestamp;
      json[_updatedAtFieldName] = seedTimestamp;
      _store[id] = json;
    }
  }

  /// Returns the full store values as raw JSON, passing through the
  /// query filter/sort seam that is currently a no-op.
  ///
  /// The seam accepts [whereDescription] for future Task 12 use and
  /// returns [input] unchanged for now.
  List<Map<String, dynamic>> _applyQueryFilterAndSort({
    required String? whereDescription,
    required List<Map<String, dynamic>> input,
  }) =>
      input;

  /// Returns a deep copy of a raw JSON map so callers cannot mutate
  /// the store.
  Map<String, dynamic> _copyRawDoc(Map<String, dynamic> doc) {
    final copy = <String, dynamic>{};
    for (final entry in doc.entries) {
      copy[entry.key] = _cloneJsonValue(entry.value);
    }
    return copy;
  }

  /// Returns a snapshot of the raw store as a list of deep-copied maps.
  List<Map<String, dynamic>> _rawStoreSnapshot() =>
      _store.values.map(_copyRawDoc).toList(growable: false);

  /// Deep-clones a JSON-compatible value.
  ///
  /// Maps and lists are recursively copied; Firestore scalar types
  /// (Timestamp, GeoPoint, Blob, String, num, bool, null) pass through.
  dynamic _cloneJsonValue(dynamic value) {
    if (value is Map<String, dynamic>) return _copyRawDoc(value);
    if (value is List) {
      return value.map(_cloneJsonValue).toList(growable: false);
    }
    return value;
  }

  /// Walks [schema] depth-first and produces a raw JSON map using the
  /// [_registry] for value generation.
  Map<String, dynamic> _generateSchemaJson(TDummySchema schema) {
    final json = <String, dynamic>{};
    for (final entry in schema.fields.entries) {
      final field = entry.value;
      switch (field) {
        case TDummySchemaLeaf(:final type):
          json[entry.key] = _registry.generate(
            field: entry.key,
            type: type,
          );
        case TDummySchemaBranch(:final nested):
          json[entry.key] = _generateSchemaJson(nested);
      }
    }
    return json;
  }

  /// Generates a complete raw JSON map for a document with the given [id].
  ///
  /// Walks the probed [_schema] depth-first, resolves each field through the
  /// [_registry], and injects [_idFieldName] with the supplied [id].
  Map<String, dynamic> _generateDocJson({required String id}) {
    final json = _generateSchemaJson(_schema);
    json[_idFieldName] = id;
    return json;
  }

  /// Pipes a stored raw JSON map through the caller's [fromJson] to produce
  /// a typed entity.
  T _materialise(Map<String, dynamic> json) =>
      _fromJsonRequired(Map<String, dynamic>.of(json));

  /// Applies timestamp fields to a raw JSON map using [TTimestampType.add].
  Map<String, dynamic> _applyTimestamps({
    required Map<String, dynamic> json,
    required TTimestampType type,
  }) {
    final copy = Map<String, dynamic>.of(json);
    return type.add(
      copy,
      createdAtFieldName: _createdAtFieldName,
      updatedAtFieldName: _updatedAtFieldName,
    );
  }

  /// Re-emits the current store snapshot to every open collection controller.
  ///
  /// Each controller receives data filtered through its stored
  /// `whereDescription` via [_applyQueryFilterAndSort]. Typed controllers
  /// get `List<T>`; raw controllers get `List<Map<String, dynamic>>`.
  void _emitCollections() {
    final rawSnapshot = _rawStoreSnapshot();

    // Typed collection controllers.
    _collectionControllers.removeWhere((ctrl) => ctrl.isClosed);
    for (final ctrl in _collectionControllers) {
      final where = _collectionControllerWhereDescriptions[ctrl];
      final filtered = _applyQueryFilterAndSort(
        whereDescription: where,
        input: rawSnapshot,
      );
      ctrl.add(filtered.map(_materialise).toList(growable: false));
    }

    // Raw collection controllers.
    _rawCollectionControllers.removeWhere((ctrl) => ctrl.isClosed);
    for (final ctrl in _rawCollectionControllers) {
      final where = _rawCollectionControllerWhereDescriptions[ctrl];
      final filtered = _applyQueryFilterAndSort(
        whereDescription: where,
        input: rawSnapshot,
      );
      ctrl.add(filtered);
    }
  }

  /// Re-emits a single document to every open controller for that [id].
  void _emitDoc(String id, T? entity) {
    final controllers = _docControllers[id];
    if (controllers == null) return;
    controllers.removeWhere((ctrl) => ctrl.isClosed);
    if (controllers.isEmpty) {
      _docControllers.remove(id);
      return;
    }
    for (final ctrl in controllers) {
      ctrl.add(entity);
    }
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Guidance message for batch/transaction write methods that are not yet
  /// implemented in dummy mode.
  static const _dummyBatchTransactionGuidance =
      'Batch/transaction writes are not yet supported by TDummyFirestoreApi. '
      'This will be wired by the batch/transaction task.';

  @override
  Future<TurboResponse<DocumentReference>> createDoc({
    required TWriteable writeable,
    String? id,
    WriteBatch? writeBatch,
    TTimestampType createTimeStampType = TTimestampType.createdAtAndUpdatedAt,
    TTimestampType updateTimeStampType = TTimestampType.updatedAt,
    bool merge = false,
    List<FieldPath>? mergeFields,
    String? collectionPathOverride,
    Transaction? transaction,
  }) async {
    assert(
      _isCollectionGroupSnapshot == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating '
      'with a collection group, therefore, you must specify the '
      'collectionPathOverride containing all parent collection and document '
      'ids in order to make this method work.',
    );
    try {
      await _applyLatency();
      final documentData = writeable.toJson();
      final failure = _rollFailureException(
        operationType: TOperationType.create,
        id: id,
        documentData: documentData,
      );
      if (failure != null) return TurboResponse.fail(error: failure);

      final TurboResponse<DocumentReference>? invalidResponse =
          writeable.validate();
      if (invalidResponse != null && invalidResponse.isFail) {
        return invalidResponse;
      }

      final effectiveId = id ?? _genDummyId();
      final json = _applyTimestamps(
        json: documentData,
        type: createTimeStampType,
      );
      json[_idFieldName] = effectiveId;

      _store[effectiveId] = Map<String, dynamic>.of(json);
      _emitCollections();
      _emitDoc(effectiveId, _materialise(_store[effectiveId]!));

      return TurboResponse.success(
        result: _TDummyDocumentReference(
          id: effectiveId,
          collectionPath: _pathSnapshot,
          firestore: _firebaseFirestoreSnapshot,
        ),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<DocumentReference>> updateDoc({
    required TWriteable writeable,
    required String id,
    WriteBatch? writeBatch,
    TTimestampType timestampType = TTimestampType.updatedAt,
    String? collectionPathOverride,
    Transaction? transaction,
  }) async {
    assert(
      _isCollectionGroupSnapshot == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating '
      'with a collection group, therefore, you must specify the '
      'collectionPathOverride containing all parent collection and document '
      'ids in order to make this method work.',
    );
    try {
      await _applyLatency();
      final documentData = writeable.toJson();
      final failure = _rollFailureException(
        operationType: TOperationType.update,
        id: id,
        documentData: documentData,
      );
      if (failure != null) return TurboResponse.fail(error: failure);

      final existing = _store[id];
      if (existing == null) {
        return TurboResponse.fail(
          error: TurboFirestoreNotFoundException(
            message: '[Dummy] ${TErrorCodes.notFoundMessage}',
            path: _pathSnapshot,
            id: id,
            operationType: TOperationType.update,
            documentData: documentData,
            stackTrace: StackTrace.current,
            originalException: FirebaseException(
              plugin: 'cloud_firestore',
              code: TErrorCodes.notFound,
              message: TErrorCodes.notFoundMessage,
            ),
          ),
        );
      }

      final TurboResponse<DocumentReference>? invalidResponse =
          writeable.validate();
      if (invalidResponse != null && invalidResponse.isFail) {
        return invalidResponse;
      }

      final updateJson = _applyTimestamps(
        json: documentData,
        type: timestampType,
      );

      // Shallow merge: overlay update keys onto existing stored map.
      final merged = Map<String, dynamic>.of(existing);
      merged.addAll(updateJson);
      // Ensure the id field never drifts from the store key.
      merged[_idFieldName] = id;

      _store[id] = merged;
      _emitCollections();
      _emitDoc(id, _materialise(merged));

      return TurboResponse.success(
        result: _TDummyDocumentReference(
          id: id,
          collectionPath: _pathSnapshot,
          firestore: _firebaseFirestoreSnapshot,
        ),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<void>> deleteDoc({
    required String id,
    WriteBatch? writeBatch,
    String? collectionPathOverride,
    Transaction? transaction,
  }) async {
    assert(
      _isCollectionGroupSnapshot == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating '
      'with a collection group, therefore, you must specify the '
      'collectionPathOverride containing all parent collection and document '
      'ids in order to make this method work.',
    );
    try {
      await _applyLatency();
      final failure = _rollFailureException(
        operationType: TOperationType.delete,
        id: id,
      );
      if (failure != null) return TurboResponse.fail(error: failure);

      _store.remove(id);
      _emitCollections();
      _emitDoc(id, null);

      return const TurboResponse.success(result: null);
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>>>
      createDocInBatch({
    required TWriteable writeable,
    String? id,
    WriteBatch? writeBatch,
    TTimestampType createTimeStampType = TTimestampType.createdAtAndUpdatedAt,
    TTimestampType updateTimeStampType = TTimestampType.updatedAt,
    bool merge = false,
    List<FieldPath>? mergeFields,
    String? collectionPathOverride,
  }) =>
      throw UnimplementedError(_dummyBatchTransactionGuidance);

  @override
  Future<TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>>>
      updateDocInBatch({
    required TWriteable writeable,
    required String id,
    WriteBatch? writeBatch,
    TTimestampType timestampType = TTimestampType.updatedAt,
    String? collectionPathOverride,
  }) =>
      throw UnimplementedError(_dummyBatchTransactionGuidance);

  @override
  Future<TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>>>
      deleteDocInBatch({
    required String id,
    WriteBatch? writeBatch,
    String? collectionPathOverride,
  }) =>
      throw UnimplementedError(_dummyBatchTransactionGuidance);

  // 🎬 DISPOSE ------------------------------------------------------------------------------- \\

  @override
  Future<void> dispose() async {
    for (final ctrl in _collectionControllers) {
      if (!ctrl.isClosed) await ctrl.close();
    }
    _collectionControllers.clear();
    _collectionControllerWhereDescriptions.clear();

    for (final ctrl in _rawCollectionControllers) {
      if (!ctrl.isClosed) await ctrl.close();
    }
    _rawCollectionControllers.clear();
    _rawCollectionControllerWhereDescriptions.clear();

    for (final controllers in _docControllers.values) {
      for (final ctrl in controllers) {
        if (!ctrl.isClosed) await ctrl.close();
      }
    }
    _docControllers.clear();

    await super.dispose();
  }
}

// ---------------------------------------------------------------------------
// _TDummyDocumentReference
// ---------------------------------------------------------------------------

/// A minimal placeholder [DocumentReference] returned by dummy write methods.
///
/// Only [id], [path], and [firestore] are functional. All other members throw
/// [UnimplementedError]. The full document reference stub ships in a later task.
class _TDummyDocumentReference
    implements DocumentReference<Map<String, dynamic>> {
  const _TDummyDocumentReference({
    required String id,
    required String collectionPath,
    required this.firestore,
  })  : _id = id,
        _collectionPath = collectionPath;

  final String _id;
  final String _collectionPath;

  static const _guidance =
      'TDummyDocumentReference is a minimal placeholder. '
      'Full implementation ships in the document-reference task.';

  @override
  String get id => _id;

  @override
  String get path => '$_collectionPath/$_id';

  @override
  final FirebaseFirestore firestore;

  @override
  CollectionReference<Map<String, dynamic>> get parent =>
      throw UnimplementedError(_guidance);

  @override
  CollectionReference<Map<String, dynamic>> collection(
    String collectionPath,
  ) =>
      throw UnimplementedError(_guidance);

  @override
  Future<void> delete() => throw UnimplementedError(_guidance);

  @override
  Future<void> update(Map<Object, Object?> data) =>
      throw UnimplementedError(_guidance);

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) =>
      throw UnimplementedError(_guidance);

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) =>
      throw UnimplementedError(_guidance);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) =>
      throw UnimplementedError(_guidance);

  @override
  DocumentReference<R> withConverter<R>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) =>
      throw UnimplementedError(_guidance);

  @override
  bool operator ==(Object other) =>
      other is _TDummyDocumentReference &&
      other._id == _id &&
      other._collectionPath == _collectionPath;

  @override
  int get hashCode => Object.hash(_id, _collectionPath);

  @override
  String toString() =>
      'DocumentReference<Map<String, dynamic>>($_collectionPath/$_id)';
}
