// ignore_for_file: subtype_of_sealed_class, undefined_hidden_name

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
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
TDummySchema probeDummySchemaForTesting<T extends TWriteable>(
  T Function(Map<String, dynamic>) fromJson,
) => _TDummyProbingMap.probe<T>(fromJson);

/// Returns the probed schema from a [TDummyFirestoreApi] instance.
@visibleForTesting
TDummySchema dummySchemaForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api) => api._schema;

/// Returns the value generator registry from a [TDummyFirestoreApi] instance.
@visibleForTesting
TValueGeneratorRegistry dummyRegistryForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api,
) => api._registry;

/// Generates a deterministic dummy id from a [TDummyFirestoreApi] instance.
@visibleForTesting
String genDummyIdForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api) => api._genDummyId();

/// Awaits the latency gate of a [TDummyFirestoreApi] instance.
@visibleForTesting
Future<void> applyDummyLatencyForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api,
) => api._applyLatency();

/// Rolls a simulated failure exception from a [TDummyFirestoreApi] instance.
@visibleForTesting
TFirestoreException? rollDummyFailureExceptionForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api, {
  required TOperationType operationType,
  String? id,
  Map<String, dynamic>? documentData,
}) => api._rollFailureException(
  operationType: operationType,
  id: id,
  documentData: documentData,
);

/// Registers a collection stream controller for testing dispose behavior.
@visibleForTesting
void addCollectionControllerForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api,
  StreamController<List<T>> controller,
) => api._collectionControllers.add(controller);

/// Registers a document stream controller for testing dispose behavior.
@visibleForTesting
void addDocControllerForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api,
  String id,
  StreamController<T?> controller,
) => (api._docControllers[id] ??= {}).add(controller);

/// Exposes the query filter/sort seam for testing.
@visibleForTesting
List<Map<String, dynamic>> applyDummyQueryFilterAndSortForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api, {
  required String? whereDescription,
  required List<Map<String, dynamic>> input,
}) => api._applyQueryFilterAndSort(
  whereDescription: whereDescription,
  input: input,
);

/// Returns the raw in-memory store for testing.
@visibleForTesting
Map<String, Map<String, dynamic>> dummyStoreForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api,
) => api._store;

/// Returns the number of active typed collection stream controllers.
@visibleForTesting
int collectionControllerCountForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api) =>
    api._collectionControllers.length;

/// Returns the number of active raw collection stream controllers.
@visibleForTesting
int rawCollectionControllerCountForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api) =>
    api._rawCollectionControllers.length;

/// Returns the number of active document stream controllers for [id].
@visibleForTesting
int docControllerCountForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api, String id) =>
    api._docControllers[id]?.length ?? 0;

/// Returns the default collection size for testing.
@visibleForTesting
int dummyDefaultCollectionSizeForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api) =>
    api._defaultCollectionSize;

/// Returns the path snapshot for testing.
@visibleForTesting
String dummyPathSnapshotForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api) =>
    api._pathSnapshot;

/// Returns the query filters for testing.
@visibleForTesting
Map<String, bool Function(Map<String, dynamic>)> dummyQueryFiltersForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api,
) => api._queryFilters;

/// Returns the query sort comparators for testing.
@visibleForTesting
Map<String, int Function(Map<String, dynamic>, Map<String, dynamic>)>
dummyQuerySortForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api) => api._querySort;

/// Generates a raw JSON map for a document with the given [id].
@visibleForTesting
Map<String, dynamic> generateDocJsonForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api, {
  required String id,
}) => api._generateDocJson(id: id);

/// Applies timestamps to a raw JSON map.
@visibleForTesting
Map<String, dynamic> applyTimestampsForTesting<T extends TWriteable>(
  TDummyFirestoreApi<T> api, {
  required Map<String, dynamic> json,
  required TTimestampType type,
}) => api._applyTimestamps(json: json, type: type);

/// Re-emits the full store snapshot to every open collection controller.
@visibleForTesting
void emitCollectionsForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api) =>
    api._emitCollections();

/// Re-emits a single document to every open controller for the given [id].
@visibleForTesting
void emitDocForTesting<T extends TWriteable>(TDummyFirestoreApi<T> api, String id, T? entity) =>
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
class TDummyFirestoreApi<T extends TWriteable> extends TFirestoreApi<T> {
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
    String searchField = 'name',
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
      querySort:
          Map<
            String,
            int Function(Map<String, dynamic>, Map<String, dynamic>)
          >.of(
            querySort ?? const {},
          ),
      pathSnapshot: pathSnapshot,
      rng: rng,
      schema: schema,
      registry: registry,
      firebaseFirestoreSnapshot: firebaseFirestore,
      isCollectionGroupSnapshot: isCollectionGroup,
      defaultSearchField: searchField,
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
    required Map<
      String,
      int Function(Map<String, dynamic>, Map<String, dynamic>)
    >
    querySort,
    required String pathSnapshot,
    required Random rng,
    required TDummySchema schema,
    required TValueGeneratorRegistry registry,
    required FirebaseFirestore firebaseFirestoreSnapshot,
    required bool isCollectionGroupSnapshot,
    required String defaultSearchField,
  }) : _firebaseFirestoreSnapshot = firebaseFirestoreSnapshot,
       _fromJsonRequired = fromJsonRequired,
       _isCollectionGroupSnapshot = isCollectionGroupSnapshot,
       _defaultSearchField = defaultSearchField,
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

  /// Default field name used by the search fallback when no explicit
  /// query filter is registered.
  final String _defaultSearchField;

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
      final filtered = _applySearchFilter(
        searchKey: searchField,
        searchTerm: searchTerm,
        searchField: searchField,
        searchTermType: searchTermType,
        doSearchNumberEquivalent: doSearchNumberEquivalent,
        limit: limit,
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
        result: _applySearchFilter(
          searchKey: searchField,
          searchTerm: searchTerm,
          searchField: searchField,
          searchTermType: searchTermType,
          doSearchNumberEquivalent: doSearchNumberEquivalent,
          limit: limit,
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
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
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
  }) => throw UnimplementedError(_dummyStreamGuidance);

  @override
  Stream<T?> streamByDocIdWithConverter({
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
    return _createDocStream(id, autoCreate: true);
  }

  /// Creates a document-specific stream controller registered in
  /// [_docControllers].
  ///
  /// When [autoCreate] is true (default), missing documents are generated
  /// and stored on first emission — matching [streamByDocIdWithConverter]
  /// behaviour. When false, missing documents emit `null` — suitable for
  /// [_TDummyDocumentReference.snapshots] where non-existent docs should
  /// report `exists == false`.
  Stream<T?> _createDocStream(String id, {bool autoCreate = true}) {
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
        if (autoCreate) {
          final stored = _getOrCreateStoredDoc(id);
          if (!controller.isClosed) controller.add(_materialise(stored));
        } else {
          final stored = _store[id];
          if (!controller.isClosed) {
            controller.add(stored != null ? _materialise(stored) : null);
          }
        }
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

  /// Applies query filtering and sorting to a raw store snapshot.
  ///
  /// When [whereDescription] is null or has no registered filter/sort,
  /// returns a shallow copy of [input] in original order. Otherwise
  /// applies the filter first (if present), then the sort (if present).
  ///
  /// Sort is guaranteed stable for tied elements via a
  /// decorate-sort-undecorate pattern that preserves insertion order.
  List<Map<String, dynamic>> _applyQueryFilterAndSort({
    required String? whereDescription,
    required List<Map<String, dynamic>> input,
  }) {
    if (whereDescription == null) return List<Map<String, dynamic>>.of(input);

    final filter = _queryFilters[whereDescription];
    final comparator = _querySort[whereDescription];

    if (filter == null && comparator == null) {
      return List<Map<String, dynamic>>.of(input);
    }

    var result = filter != null
        ? input.where(filter).toList()
        : List<Map<String, dynamic>>.of(input);

    if (comparator != null) {
      // Decorate-sort-undecorate to guarantee stable sort for tied elements.
      final decorated = [
        for (var i = 0; i < result.length; i++) (index: i, doc: result[i]),
      ];
      decorated.sort((a, b) {
        final cmp = comparator(a.doc, b.doc);
        return cmp != 0 ? cmp : a.index.compareTo(b.index);
      });
      result = [for (final e in decorated) e.doc];
    }

    return result;
  }

  /// Applies search-specific filtering with substring fallback.
  ///
  /// If [_queryFilters] contains [searchKey], delegates entirely to
  /// [_applyQueryFilterAndSort]. Otherwise, performs a case-insensitive
  /// substring match on the [searchField] (falling back to
  /// [_defaultSearchField]) of each document. Documents that lack the
  /// field or have a non-String value pass through unfiltered.
  ///
  /// After filtering, applies any matching sort from [_querySort], then
  /// truncates to [limit] if non-null.
  ///
  /// Branches on [searchTermType]:
  /// - [TSearchTermType.startsWith]: prefix match on String fields
  /// - [TSearchTermType.arrayContains]: membership check on List fields
  ///
  /// When [doSearchNumberEquivalent] is true and the [searchTerm] parses as
  /// a number, numeric fields are matched by equality.
  ///
  /// Documents whose target field is missing or has an incompatible type are
  /// treated as non-matches (filtered out).
  List<Map<String, dynamic>> _applySearchFilter({
    required String searchKey,
    required String searchTerm,
    required String searchField,
    required TSearchTermType searchTermType,
    required bool doSearchNumberEquivalent,
    required int? limit,
    required List<Map<String, dynamic>> input,
  }) {
    List<Map<String, dynamic>> result;

    if (_queryFilters.containsKey(searchKey)) {
      // Registered filter takes full precedence (including sort).
      result = _applyQueryFilterAndSort(
        whereDescription: searchKey,
        input: input,
      );
    } else {
      // Prefer the method-level searchField; fall back to constructor default.
      final targetField = input.any((doc) => doc[searchField] is String)
          ? searchField
          : _defaultSearchField;
      final termLower = searchTerm.toLowerCase();
      final numericTerm = doSearchNumberEquivalent
          ? num.tryParse(searchTerm)
          : null;

      result = input.where((doc) {
        final value = doc[targetField];

        // Number equivalence check.
        if (numericTerm != null && value is num) {
          return value == numericTerm;
        }

        switch (searchTermType) {
          case TSearchTermType.startsWith:
            if (value is! String) return false;
            return value.toLowerCase().startsWith(termLower);
          case TSearchTermType.arrayContains:
            if (value is List) return value.contains(searchTerm);
            return false;
        }
      }).toList();

      // Apply sort if one is registered for this search key.
      final comparator = _querySort[searchKey];
      if (comparator != null) {
        final decorated = [
          for (var i = 0; i < result.length; i++) (index: i, doc: result[i]),
        ];
        decorated.sort((a, b) {
          final cmp = comparator(a.doc, b.doc);
          return cmp != 0 ? cmp : a.index.compareTo(b.index);
        });
        result = [for (final e in decorated) e.doc];
      }
    }

    if (limit != null && result.length > limit) {
      result = result.sublist(0, limit);
    }

    return result;
  }

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

  // 🔗 DOCUMENT REFERENCES -------------------------------------------------------------------- \\

  @override
  DocumentReference<Map<String, dynamic>> getDocRefById({
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
    return _TDummyDocumentReference<Map<String, dynamic>, T>.raw(
      api: this,
      id: id,
    );
  }

  @override
  DocumentReference<T> getDocRefByIdWithConverter({
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
    return _TDummyDocumentReference<T, T>.converted(api: this, id: id);
  }

  /// Raw map update used by [_TDummyDocumentReference.update].
  ///
  /// Applies latency + failure gate, shallow-merges [data] onto the stored
  /// map, applies [TTimestampType.updatedAt] timestamps, preserves
  /// [_idFieldName], and emits collection + doc streams.
  Future<void> _rawUpdateById({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _applyLatency();
    final failure = _rollFailureException(
      operationType: TOperationType.update,
      id: id,
      documentData: data,
    );
    if (failure != null) throw failure;

    final existing = _store[id];
    if (existing == null) {
      throw _notFoundExceptionFor(id: id, documentData: data);
    }

    final updateJson = _applyTimestamps(
      json: data,
      type: TTimestampType.updatedAt,
    );
    final merged = Map<String, dynamic>.of(existing);
    merged.addAll(updateJson);
    merged[_idFieldName] = id;

    _store[id] = merged;
    _emitCollections();
    _emitDoc(id, _materialise(merged));
  }

  /// Raw map set (overwrite) used by [_TDummyDocumentReference.set].
  ///
  /// Applies latency + failure gate, overwrites the stored map with [data],
  /// applies [TTimestampType.createdAtAndUpdatedAt] timestamps for new docs
  /// or preserves existing createdAt for overwrites, and emits streams.
  Future<void> _rawSetById({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _applyLatency();
    final isCreate = !_store.containsKey(id);
    final failure = _rollFailureException(
      operationType: isCreate ? TOperationType.create : TOperationType.update,
      id: id,
      documentData: data,
    );
    if (failure != null) throw failure;

    final json = Map<String, dynamic>.of(data);
    if (isCreate) {
      final timestamped = _applyTimestamps(
        json: json,
        type: TTimestampType.createdAtAndUpdatedAt,
      );
      timestamped[_idFieldName] = id;
      _store[id] = timestamped;
    } else {
      // Preserve existing createdAt, refresh updatedAt.
      final existing = _store[id]!;
      final createdAt = existing[_createdAtFieldName];
      final timestamped = _applyTimestamps(
        json: json,
        type: TTimestampType.updatedAt,
      );
      timestamped[_idFieldName] = id;
      if (createdAt != null) {
        timestamped[_createdAtFieldName] = createdAt;
      }
      _store[id] = timestamped;
    }

    _emitCollections();
    _emitDoc(id, _materialise(_store[id]!));
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  // _dummyModeGuidance is intentionally on the API class so the private
  // batch/transaction classes can reference it via their owning api.
  static const _dummyModeGuidance = // ignore: unused_field
      'dummy-mode: this WriteBatch/Transaction method is not stubbed; '
      'override in feature wiring or add it to the dummy api.';

  /// Commits a dummy batch response and returns the document reference.
  ///
  /// Equivalent to the base class's `_handleBatchOperation` but accessible
  /// from the dummy library.
  Future<TurboResponse<DocumentReference>> _commitDummyBatch(
    TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>> batchResponse,
  ) async {
    return batchResponse.when(
      success: (success) async {
        await success.result.writeBatch.commit();
        return TurboResponse.success(
          result: success.result.documentReference,
        );
      },
      fail: (fail) => TurboResponse.fail(error: fail.error),
    );
  }

  @override
  WriteBatch get writeBatch => _TDummyWriteBatch<T>._(api: this);

  @override
  Future<E> runTransaction<E>(
    TransactionHandler<E> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    final txn = _TDummyTransaction<T>._(api: this);
    // Snapshot store for rollback — transactions are all-or-nothing.
    final snapshot = {
      for (final e in _store.entries) e.key: Map<String, dynamic>.of(e.value),
    };
    final E result;
    try {
      result = await transactionHandler(txn);
    } catch (_) {
      // Restore store on failure.
      _store
        ..clear()
        ..addAll(snapshot);
      rethrow;
    }
    // Emit once for all mutations the handler performed.
    if (txn._touchedIds.isNotEmpty) {
      _emitCollections();
      for (final id in txn._touchedIds) {
        final stored = _store[id];
        _emitDoc(id, stored != null ? _materialise(stored) : null);
      }
    }
    return result;
  }

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

    // Batch path — delegate to batch helper then commit immediately.
    if (writeBatch != null) {
      final batchResponse = await createDocInBatch(
        writeable: writeable,
        id: id,
        writeBatch: writeBatch,
        createTimeStampType: createTimeStampType,
        updateTimeStampType: updateTimeStampType,
        merge: merge,
        mergeFields: mergeFields,
        collectionPathOverride: collectionPathOverride,
      );
      return _commitDummyBatch(batchResponse);
    }

    // Transaction path — mutate store inline, no emission (transaction
    // finalisation emits once).
    if (transaction != null) {
      try {
        final TurboResponse<DocumentReference>? invalidResponse = writeable
            .validate();
        if (invalidResponse != null && invalidResponse.isFail) {
          return invalidResponse;
        }
        final effectiveId = id ?? _genDummyId();
        final documentData = writeable.toJson();
        final json = _applyTimestamps(
          json: documentData,
          type: createTimeStampType,
        );
        json[_idFieldName] = effectiveId;
        _store[effectiveId] = Map<String, dynamic>.of(json);
        if (transaction is _TDummyTransaction<T>) {
          transaction._touchedIds.add(effectiveId);
        }
        return TurboResponse.success(
          result: _TDummyDocumentReference<Map<String, dynamic>, T>.raw(
            api: this,
            id: effectiveId,
          ),
        );
      } catch (error) {
        return TurboResponse.fail(error: error);
      }
    }

    // Direct path — validate first, then latency + failure gate + emission.
    try {
      final TurboResponse<DocumentReference>? invalidResponse = writeable
          .validate();
      if (invalidResponse != null && invalidResponse.isFail) {
        return invalidResponse;
      }

      await _applyLatency();
      final documentData = writeable.toJson();
      final failure = _rollFailureException(
        operationType: TOperationType.create,
        id: id,
        documentData: documentData,
      );
      if (failure != null) return TurboResponse.fail(error: failure);

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
        result: _TDummyDocumentReference<Map<String, dynamic>, T>.raw(
          api: this,
          id: effectiveId,
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

    // Batch path.
    if (writeBatch != null) {
      final batchResponse = await updateDocInBatch(
        writeable: writeable,
        id: id,
        writeBatch: writeBatch,
        timestampType: timestampType,
        collectionPathOverride: collectionPathOverride,
      );
      return _commitDummyBatch(batchResponse);
    }

    // Transaction path — mutate inline, no emission.
    if (transaction != null) {
      try {
        final documentData = writeable.toJson();
        final existing = _store[id];
        if (existing == null) {
          return TurboResponse.fail(
            error: _notFoundExceptionFor(id: id, documentData: documentData),
          );
        }
        final TurboResponse<DocumentReference>? invalidResponse = writeable
            .validate();
        if (invalidResponse != null && invalidResponse.isFail) {
          return invalidResponse;
        }
        final updateJson = _applyTimestamps(
          json: documentData,
          type: timestampType,
        );
        final merged = Map<String, dynamic>.of(existing);
        merged.addAll(updateJson);
        merged[_idFieldName] = id;
        _store[id] = merged;
        if (transaction is _TDummyTransaction<T>) {
          transaction._touchedIds.add(id);
        }
        return TurboResponse.success(
          result: _TDummyDocumentReference<Map<String, dynamic>, T>.raw(
            api: this,
            id: id,
          ),
        );
      } catch (error) {
        return TurboResponse.fail(error: error);
      }
    }

    // Direct path — validate first, then latency + failure gate + emission.
    try {
      final TurboResponse<DocumentReference>? invalidResponse = writeable
          .validate();
      if (invalidResponse != null && invalidResponse.isFail) {
        return invalidResponse;
      }

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
          error: _notFoundExceptionFor(id: id, documentData: documentData),
        );
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
        result: _TDummyDocumentReference<Map<String, dynamic>, T>.raw(
          api: this,
          id: id,
        ),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  /// Creates a [TurboFirestoreNotFoundException] for the given [id].
  TurboFirestoreNotFoundException _notFoundExceptionFor({
    required String id,
    Map<String, dynamic>? documentData,
  }) => TurboFirestoreNotFoundException(
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
  );

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

    // Batch path.
    if (writeBatch != null) {
      final batchResponse = await deleteDocInBatch(
        id: id,
        writeBatch: writeBatch,
        collectionPathOverride: collectionPathOverride,
      );
      return _commitDummyBatch(batchResponse).then(
        (_) => const TurboResponse<void>.success(result: null),
      );
    }

    // Transaction path — mutate inline, no emission.
    if (transaction != null) {
      _store.remove(id);
      if (transaction is _TDummyTransaction<T>) {
        transaction._touchedIds.add(id);
      }
      return const TurboResponse.success(result: null);
    }

    // Direct path.
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
  }) async {
    assert(
      _isCollectionGroupSnapshot == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating '
      'with a collection group, therefore, you must specify the '
      'collectionPathOverride containing all parent collection and document '
      'ids in order to make this method work.',
    );
    try {
      final TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>>?
      invalidResponse = writeable.validate();
      if (invalidResponse != null && invalidResponse.isFail) {
        return invalidResponse;
      }

      final batch = writeBatch is _TDummyWriteBatch<T>
          ? writeBatch
          : (writeBatch ?? this.writeBatch) as _TDummyWriteBatch<T>;

      final effectiveId = id ?? _genDummyId();
      final docRef = _TDummyDocumentReference<Map<String, dynamic>, T>.raw(
        api: this,
        id: effectiveId,
      );

      final documentData = writeable.toJson();
      batch._enqueue(
        id: effectiveId,
        apply: () {
          final json = _applyTimestamps(
            json: documentData,
            type: createTimeStampType,
          );
          json[_idFieldName] = effectiveId;
          _store[effectiveId] = Map<String, dynamic>.of(json);
        },
      );

      return TurboResponse.success(
        result: TWriteBatchWithReference(
          writeBatch: batch,
          documentReference: docRef,
        ),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>>>
  updateDocInBatch({
    required TWriteable writeable,
    required String id,
    WriteBatch? writeBatch,
    TTimestampType timestampType = TTimestampType.updatedAt,
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
      final TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>>?
      invalidResponse = writeable.validate();
      if (invalidResponse != null && invalidResponse.isFail) {
        return invalidResponse;
      }

      final batch = writeBatch is _TDummyWriteBatch<T>
          ? writeBatch
          : (writeBatch ?? this.writeBatch) as _TDummyWriteBatch<T>;

      final docRef = _TDummyDocumentReference<Map<String, dynamic>, T>.raw(
        api: this,
        id: id,
      );

      final documentData = writeable.toJson();
      batch._enqueue(
        id: id,
        apply: () {
          final existing = _store[id];
          if (existing == null) {
            throw _notFoundExceptionFor(id: id, documentData: documentData);
          }
          final updateJson = _applyTimestamps(
            json: documentData,
            type: timestampType,
          );
          final merged = Map<String, dynamic>.of(existing);
          merged.addAll(updateJson);
          merged[_idFieldName] = id;
          _store[id] = merged;
        },
      );

      return TurboResponse.success(
        result: TWriteBatchWithReference(
          writeBatch: batch,
          documentReference: docRef,
        ),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

  @override
  Future<TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>>>
  deleteDocInBatch({
    required String id,
    WriteBatch? writeBatch,
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
      final batch = writeBatch is _TDummyWriteBatch<T>
          ? writeBatch
          : (writeBatch ?? this.writeBatch) as _TDummyWriteBatch<T>;

      final docRef = _TDummyDocumentReference<Map<String, dynamic>, T>.raw(
        api: this,
        id: id,
      );

      batch._enqueue(
        id: id,
        apply: () => _store.remove(id),
      );

      return TurboResponse.success(
        result: TWriteBatchWithReference(
          writeBatch: batch,
          documentReference: docRef,
        ),
      );
    } catch (error) {
      return TurboResponse.fail(error: error);
    }
  }

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
// _TDummyWriteBatch
// ---------------------------------------------------------------------------

/// A library-private dummy [WriteBatch] that queues mutation closures and
/// applies them in order on [commit], emitting exactly one collection
/// snapshot for the entire batch.
class _TDummyWriteBatch<T extends TWriteable> implements WriteBatch {
  _TDummyWriteBatch._({required TDummyFirestoreApi<T> api}) : _api = api;

  final TDummyFirestoreApi<T> _api;
  final List<({String id, void Function() apply})> _queue = [];
  bool _committed = false;

  /// Enqueues a mutation closure tagged with its affected [id].
  void _enqueue({required String id, required void Function() apply}) {
    if (_committed) {
      throw StateError(
        'dummy-mode: WriteBatch has already been committed; '
        'create a new batch for further operations.',
      );
    }
    _queue.add((id: id, apply: apply));
  }

  @override
  Future<void> commit() async {
    if (_committed) {
      throw StateError(
        'dummy-mode: WriteBatch has already been committed; '
        'create a new batch for further operations.',
      );
    }
    _committed = true;

    // Snapshot store for rollback — batches are all-or-nothing.
    final snapshot = {
      for (final e in _api._store.entries)
        e.key: Map<String, dynamic>.of(e.value),
    };

    final appliedIds = <String>{};
    try {
      for (final op in _queue) {
        op.apply();
        appliedIds.add(op.id);
      }
    } catch (_) {
      // Restore store on failure.
      _api._store
        ..clear()
        ..addAll(snapshot);
      rethrow;
    }

    // Single collection emission for the entire batch.
    _api._emitCollections();
    for (final id in appliedIds) {
      final stored = _api._store[id];
      _api._emitDoc(
        id,
        stored != null ? _api._materialise(stored) : null,
      );
    }
  }

  @override
  void delete(DocumentReference<Object?> document) {
    _enqueue(
      id: document.id,
      apply: () => _api._store.remove(document.id),
    );
  }

  @override
  void set<R>(DocumentReference<R> document, R data, [SetOptions? options]) {
    if (data is! Map<String, dynamic>) {
      throw UnimplementedError(
        'dummy-mode: WriteBatch.set only accepts Map<String, dynamic> data.',
      );
    }
    _enqueue(
      id: document.id,
      apply: () {
        _api._store[document.id] = Map<String, dynamic>.of(data);
      },
    );
  }

  @override
  void update(
    DocumentReference<Object?> document,
    Map<Object, Object?> data,
  ) {
    final castData = Map<String, dynamic>.from(data);
    _enqueue(
      id: document.id,
      apply: () {
        final existing = _api._store[document.id];
        if (existing == null) {
          throw _api._notFoundExceptionFor(
            id: document.id,
            documentData: castData,
          );
        }
        final merged = Map<String, dynamic>.of(existing);
        merged.addAll(castData);
        merged[_api._idFieldName] = document.id;
        _api._store[document.id] = merged;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _TDummyTransaction
// ---------------------------------------------------------------------------

/// A library-private dummy [Transaction] that reads and writes [_store]
/// directly inside a [runTransaction] handler.
///
/// Mutations are applied inline (immediately visible within the handler).
/// The [runTransaction] override emits once after the handler returns.
class _TDummyTransaction<T extends TWriteable> implements Transaction {
  _TDummyTransaction._({required TDummyFirestoreApi<T> api}) : _api = api;

  final TDummyFirestoreApi<T> _api;

  /// Ids mutated during the handler — used by [runTransaction] for
  /// post-handler emission.
  final Set<String> _touchedIds = {};

  @override
  Future<DocumentSnapshot<R>> get<R extends Object?>(
    DocumentReference<R> documentReference,
  ) async {
    final stored = _api._store[documentReference.id];
    if (stored == null) {
      return _TDummyDocumentSnapshot<R>._(
        id: documentReference.id,
        reference: documentReference,
        data: null,
        exists: false,
      );
    }
    // Materialise through fromJson for converted refs; deep-copy for raw.
    final R data;
    if (documentReference is _TDummyDocumentReference<R, T> &&
        !documentReference._isRaw) {
      data = _api._materialise(stored) as R;
    } else {
      data = _api._copyRawDoc(stored) as R;
    }
    return _TDummyDocumentSnapshot<R>._(
      id: documentReference.id,
      reference: documentReference,
      data: data,
      exists: true,
    );
  }

  @override
  Transaction delete(DocumentReference<Object?> documentReference) {
    _api._store.remove(documentReference.id);
    _touchedIds.add(documentReference.id);
    return this;
  }

  @override
  Transaction set<R>(
    DocumentReference<R> documentReference,
    R data, [
    SetOptions? options,
  ]) {
    if (data is! Map<String, dynamic>) {
      throw UnimplementedError(
        'dummy-mode: Transaction.set only accepts Map<String, dynamic> data.',
      );
    }
    _api._store[documentReference.id] = Map<String, dynamic>.of(data);
    _touchedIds.add(documentReference.id);
    return this;
  }

  @override
  Transaction update(
    DocumentReference<Object?> documentReference,
    Map<Object, Object?> data,
  ) {
    final castData = Map<String, dynamic>.from(data);
    final existing = _api._store[documentReference.id];
    if (existing == null) {
      throw _api._notFoundExceptionFor(
        id: documentReference.id,
        documentData: castData,
      );
    }
    final merged = Map<String, dynamic>.of(existing);
    merged.addAll(castData);
    merged[_api._idFieldName] = documentReference.id;
    _api._store[documentReference.id] = merged;
    _touchedIds.add(documentReference.id);
    return this;
  }
}

// ---------------------------------------------------------------------------
// _TDummyDocumentSnapshot
// ---------------------------------------------------------------------------

/// Minimal document snapshot stub returned by [_TDummyTransaction.get].
class _TDummyDocumentSnapshot<T extends Object?>
    implements DocumentSnapshot<T> {
  const _TDummyDocumentSnapshot._({
    required this.id,
    required this.reference,
    required T? data,
    required this.exists,
  }) : _data = data;

  @override
  final String id;

  @override
  final DocumentReference<T> reference;

  @override
  final bool exists;

  final T? _data;

  @override
  T? data() => _data;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError(
    'dummy-mode: SnapshotMetadata is not available in dummy document '
    'snapshots.',
  );

  @override
  dynamic get(Object field) => throw UnimplementedError(
    'dummy-mode: DocumentSnapshot.get is not available in dummy document '
    'snapshots. Use data() instead.',
  );

  @override
  dynamic operator [](Object field) => get(field);
}

// ---------------------------------------------------------------------------
// _TDummyDocumentReference
// ---------------------------------------------------------------------------

/// A [DocumentReference] stub that delegates to the owning
/// [TDummyFirestoreApi]'s in-memory store.
///
/// Supports two modes:
/// - **raw** — implements `DocumentReference<Map<String, dynamic>>` for
///   [getDocRefById] and write-method return values.
/// - **converted** — implements `DocumentReference<T>` for
///   [getDocRefByIdWithConverter].
///
/// Supported members: [id], [path], [firestore], [get], [update], [delete],
/// [set], [snapshots]. Unsupported members throw [UnimplementedError] with
/// a dummy-mode guidance message.
class _TDummyDocumentReference<D, T extends TWriteable> implements DocumentReference<D> {
  /// Creates a raw-mode reference returning `Map<String, dynamic>` data.
  _TDummyDocumentReference.raw({
    required TDummyFirestoreApi<T> api,
    required String id,
  }) : _api = api,
       _id = id,
       _isRaw = true;

  /// Creates a converted-mode reference returning typed `T` data.
  _TDummyDocumentReference.converted({
    required TDummyFirestoreApi<T> api,
    required String id,
  }) : _api = api,
       _id = id,
       _isRaw = false;

  final TDummyFirestoreApi<T> _api;
  final String _id;
  final bool _isRaw;

  @override
  String get id => _id;

  @override
  String get path => '${_api._pathSnapshot}/$_id';

  @override
  FirebaseFirestore get firestore => _api._firebaseFirestoreSnapshot;

  @override
  Future<DocumentSnapshot<D>> get([GetOptions? options]) async {
    await _api._applyLatency();
    final failure = _api._rollFailureException(
      operationType: TOperationType.read,
      id: _id,
    );
    if (failure != null) throw failure;

    final stored = _api._store[_id];
    if (stored == null) {
      return _TDummyDocumentSnapshot<D>._(
        id: _id,
        reference: this,
        data: null,
        exists: false,
      );
    }

    final D data =
        (_isRaw ? _api._copyRawDoc(stored) : _api._materialise(stored)) as D;
    return _TDummyDocumentSnapshot<D>._(
      id: _id,
      reference: this,
      data: data,
      exists: true,
    );
  }

  @override
  Future<void> update(Map<Object, Object?> data) {
    // Reject non-string keys (FieldPath not supported).
    for (final key in data.keys) {
      if (key is! String) {
        throw UnimplementedError(
          'dummy-mode: DocumentReference.update only supports String keys; '
          'FieldPath keys are not stubbed.',
        );
      }
    }
    return _api._rawUpdateById(
      id: _id,
      data: Map<String, dynamic>.from(data),
    );
  }

  @override
  Future<void> delete() async {
    final response = await _api.deleteDoc(id: _id);
    response.when(
      success: (_) {},
      fail: (fail) => throw fail.error,
    );
  }

  @override
  Future<void> set(D data, [SetOptions? options]) {
    if (data is Map<String, dynamic>) {
      return _api._rawSetById(id: _id, data: data);
    }
    // Converted mode: serialise typed entity via TWriteable.toJson().
    if (data is TWriteable) {
      return _api._rawSetById(id: _id, data: data.toJson());
    }
    throw UnimplementedError(
      'dummy-mode: DocumentReference.set only supports '
      'Map<String, dynamic> or TWriteable data.',
    );
  }

  @override
  Stream<DocumentSnapshot<D>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    // Use autoCreate: false so absent docs emit exists == false instead
    // of being silently generated.
    return _api._createDocStream(_id, autoCreate: false).map((entity) {
      if (entity == null) {
        return _TDummyDocumentSnapshot<D>._(
          id: _id,
          reference: this,
          data: null,
          exists: false,
        );
      }
      final D data =
          (_isRaw
                  ? (_api._store[_id] != null
                        ? _api._copyRawDoc(_api._store[_id]!)
                        : null)
                  : entity)
              as D;
      return _TDummyDocumentSnapshot<D>._(
        id: _id,
        reference: this,
        data: data,
        exists: true,
      );
    });
  }

  @override
  CollectionReference<D> get parent => throw UnimplementedError(
    'dummy-mode: DocumentReference.parent is not stubbed; '
    'if your feature needs it, extend _TDummyDocumentReference.',
  );

  @override
  CollectionReference<Map<String, dynamic>> collection(
    String collectionPath,
  ) => throw UnimplementedError(
    'dummy-mode: DocumentReference.collection is not stubbed; '
    'if your feature needs it, extend _TDummyDocumentReference.',
  );

  @override
  DocumentReference<R> withConverter<R>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) => throw UnimplementedError(
    'dummy-mode: DocumentReference.withConverter is not stubbed; '
    'if your feature needs it, extend _TDummyDocumentReference.',
  );

  @override
  bool operator ==(Object other) =>
      other is _TDummyDocumentReference<D, T> &&
      identical(_api, other._api) &&
      other._id == _id;

  @override
  int get hashCode => Object.hash(identityHashCode(_api), _id);

  @override
  String toString() =>
      'DocumentReference<${_isRaw ? 'Map<String, dynamic>' : T}>'
      '(${_api._pathSnapshot}/$_id)';
}
