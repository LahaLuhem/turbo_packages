import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
import 'package:turbo_firestore_api/abstracts/t_firestore_cache_service.dart';
import 'package:turbo_firestore_api/constants/t_firestore_api_defaults.dart';
import 'package:turbo_firestore_api/enums/t_operation_type.dart';
import 'package:turbo_firestore_api/enums/t_search_term_type.dart';
import 'package:turbo_firestore_api/enums/t_timestamp_type.dart';
import 'package:turbo_firestore_api/exceptions/invalid_json_exception.dart';
import 'package:turbo_firestore_api/exceptions/t_firestore_exception.dart';
import 'package:turbo_firestore_api/extensions/t_map_extension.dart';
import 'package:turbo_firestore_api/models/t_sensitive_data.dart';
import 'package:turbo_firestore_api/models/t_write_batch_with_reference.dart';
import 'package:turbo_firestore_api/typedefs/collection_reference_def.dart';
import 'package:turbo_firestore_api/util/t_firestore_logger.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

part 't_firestore_create_api.dart';
part 't_firestore_delete_api.dart';
part 't_firestore_get_api.dart';
part 't_firestore_list_api.dart';
part 't_firestore_search_api.dart';
part 't_firestore_stream_api.dart';
part 't_firestore_update_api.dart';

/// Library-private base class that holds all state and helpers for [TFirestoreApi].
///
/// Operation-family mixins constrain on this base to access private fields
/// and helpers while remaining in separate part files for code organization.
abstract class _TFirestoreApiBase<T> {
  _TFirestoreApiBase({
    required FirebaseFirestore firebaseFirestore,
    required String Function() collectionPath,
    Map<String, dynamic> Function(T value)? toJson,
    T Function(Map<String, dynamic> json)? fromJson,
    T Function(Map<String, dynamic> json)? fromJsonError,
    bool tryAddLocalId = TFirestoreApiDefaults.tryAddLocalId,
    TFirestoreLogger? logger,
    String createdAtFieldName = TFirestoreApiDefaults.createdAtFieldName,
    String updatedAtFieldName = TFirestoreApiDefaults.updatedAtFieldName,
    String idFieldName = TFirestoreApiDefaults.idFieldName,
    this.userIdFieldName = TFirestoreApiDefaults.userIdFieldName,
    String documentReferenceFieldName = TFirestoreApiDefaults.documentReferenceFieldName,
    bool isCollectionGroup = TFirestoreApiDefaults.isCollectionGroup,
    bool tryAddLocalDocumentReference = TFirestoreApiDefaults.tryAddLocalDocumentReference,
    GetOptions? getOptions,
    this.unknownId = TFirestoreApiDefaults.unknownIdFallback,
    this.defaultId = TFirestoreApiDefaults.defaultId,
    TFirestoreCache? firestoreCache,
  }) : _firestoreCache = firestoreCache,
       _firebaseFirestore = firebaseFirestore,
       _collectionPath = collectionPath,
       _toJson = toJson,
       _fromJson = fromJson,
       _fromJsonError = fromJsonError,
       _tryAddLocalId = tryAddLocalId,
       _log = logger ?? TFirestoreLogger(),
       _createdAtFieldName = createdAtFieldName,
       _updatedAtFieldName = updatedAtFieldName,
       _idFieldName = idFieldName,
       _documentReferenceFieldName = documentReferenceFieldName,
       _isCollectionGroup = isCollectionGroup,
       _tryAddLocalDocumentReference = tryAddLocalDocumentReference,
       _getOptions = getOptions;

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  /// Used to performs Firestore operations.
  final FirebaseFirestore _firebaseFirestore;

  /// Used to find the Firestore collection.
  final String Function() _collectionPath;

  /// Used to serialize your data to JSON when using 'WithConverter' methods.
  final Map<String, dynamic> Function(T value)? _toJson;

  /// Used to deserialize your data to JSON when using 'WithConverter' methods.
  final T Function(Map<String, dynamic> json)? _fromJson;

  /// Used to deserialize your data to JSON when using 'WithConverter' methods and a data error occurs.
  ///
  /// Use this to create a default object to show to the user in case parsing your data goes wrong.
  /// This is especially useful when you are working with iterables of the same type.
  /// Because now when an error occurs it will use a default object and parsing of the other objects
  /// that have no errors can continue. Whereas before it would just throw an error and stop parsing.
  final T Function(Map<String, dynamic> json)? _fromJsonError;

  /// Used to add an id field to any of your local Firestore data (so not actually in Firestore).
  ///
  /// If this is true then your data will have an id field added based on the [_idFieldName]
  /// specified in the constructor. Add this id field to the model you're serializing to and you
  /// will have easy access to the document id at any time. Any create or update method will by
  /// default try te remove the field again before writing to Firestore (unless specified otherwise).
  ///
  /// Setting this to true will also try to remove the field when deserializing.
  final bool _tryAddLocalId;

  /// Used to add a [DocumentReference] field to any of your local Firestore data (so not actually in Firestore).
  ///
  /// If this is true then your data will have an id field added based on the [_idFieldName]
  /// specified in the constructor. Add this id field to the model you're serializing to and you
  /// will have easy access to the document id at any time. Any create or update method will by
  /// default try te remove the field again before writing to Firestore (unless specified otherwise).
  ///
  /// Setting this to true will also try to remove the field when deserializing.
  final bool _tryAddLocalDocumentReference;

  /// Used to provide proper logging when performing any operation inside the [TFirestoreApi].
  final TFirestoreLogger _log;

  /// Used to provide a default 'createdAt' field based on the provided [TTimestampType] of create methods.
  final String _createdAtFieldName;

  /// Used to provide a default 'updatedAt' field based on the provided [TTimestampType] of update methods.
  final String _updatedAtFieldName;

  /// Used to provide an id field to your create/update methods if necessary.
  ///
  /// May also be used to provide an id field to your data from Firestore when fetching data.
  final String _idFieldName;

  /// Used to provide a userId field to your create/update methods if necessary.
  final String userIdFieldName;

  /// Used to provide an unknown id for unknown objects.
  final String unknownId;

  /// Used to provide a default id for default objects.
  final String defaultId;

  /// Used to provide a reference field to your create/update methods if necessary.
  ///
  /// May also be used to provide an id field to your data from Firestore when fetching data.
  final String _documentReferenceFieldName;

  /// Whether the [_collectionPath] refers to a collection group.
  final bool _isCollectionGroup;

  /// An options class that configures the behavior of get() calls on [DocumentReference] and [Query].
  final GetOptions? _getOptions;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Helper method to fetch a [WriteBatch] from [_firebaseFirestore]..
  WriteBatch get writeBatch => _firebaseFirestore.batch();

  /// The current collection
  CollectionReference get collection => _firebaseFirestore.collection(_collectionPath());

  /// A new document
  DocumentReference get doc => collection.doc();

  /// Generates a new document ID without creating the document
  String get genId => doc.id;

  /// Used to cache Firestore documents and queries for faster access and offline support.
  final TFirestoreCache? _firestoreCache;

  /// Used to determined if a document exists based on given [id].
  Future<bool> docExists({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    final docRef = getDocRefById(
      id: id,
      collectionPathOverride: collectionPathOverride,
    );
    _log.debug(
      message: 'Checking if document exists..',
      sensitiveData: TSensitiveData(
        path: collectionPathOverride ?? _collectionPath(),
        id: id,
      ),
    );
    return (await docRef.get(_getOptions)).exists;
  }

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  /// Safely extracts document data from a writeable object.
  ///
  /// Returns the JSON representation of the writeable, or null if conversion fails.
  Map<String, dynamic>? _extractDocumentData(TWriteable? writeable) {
    if (writeable == null) return null;
    try {
      return writeable.toJson();
    } catch (_) {
      // Ignore conversion errors
      return null;
    }
  }

  /// Constructs a full document path from collection path and document ID.
  ///
  /// Returns the full path (collection/id) if both are provided,
  /// otherwise returns just the collection path.
  String _buildFullPath(String path, String? id) {
    if (id != null) {
      return '$path/$id';
    }
    return path;
  }

  /// Helper method to get the effective collection path, considering overrides.
  String _pPath(String? collectionPathOverride) => collectionPathOverride ?? _collectionPath();

  /// Creates a TFirestoreException with extracted context.
  ///
  /// This helper extracts document data and builds the exception with full context.
  /// The caller is responsible for logging and handling the exception.
  ///
  /// Parameters:
  /// - [error] - The error that occurred
  /// - [stackTrace] - The stack trace associated with the error
  /// - [path] - The collection path where the error occurred
  /// - [id] - Optional document ID where the error occurred
  /// - [operationType] - The type of operation being performed
  /// - [query] - Optional query description
  /// - [writeable] - Optional writeable object to extract document data from
  /// - [documentData] - Optional pre-extracted document data
  ///
  /// Returns a TFirestoreException with full context.
  TFirestoreException _createException({
    required Object error,
    required StackTrace stackTrace,
    required String path,
    String? id,
    required TOperationType operationType,
    String? query,
    TWriteable? writeable,
    Map<String, dynamic>? documentData,
  }) {
    final extractedData = documentData ?? _extractDocumentData(writeable);
    return TFirestoreException.fromFirestoreException(
      error,
      stackTrace,
      path: path,
      id: id,
      query: query,
      operationType: operationType,
      documentData: extractedData,
    );
  }

  /// Helper method for logging the length of a List result.
  void _logResultLength(List<dynamic> result) {
    if (result.isNotEmpty) {
      _log.info(
        message: 'Found ${result.length} item(s)!',
        sensitiveData: TSensitiveData(
          path: _collectionPath(),
        ),
      );
    } else {
      _log.warning(
        message: 'Found 0 items!',
        sensitiveData: TSensitiveData(
          path: _collectionPath(),
        ),
      );
    }
  }

  /// Helper method to handle batch responses and extract the result.
  ///
  /// This method properly unwraps the TurboResponse and handles error cases.
  TWriteBatchWithReference<Map<String, dynamic>>? _handleBatchResponse(
    TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>> response,
  ) {
    return response.when<TWriteBatchWithReference<Map<String, dynamic>>?>(
      success: (success) => success.result,
      fail: (_) => null,
    );
  }

  /// Helper method to handle batch operations.
  ///
  /// This method properly handles the batch response and executes the commit operation.
  Future<TurboResponse<DocumentReference>> _handleBatchOperation(
    TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>> batchResponse,
  ) async {
    final batchResult = _handleBatchResponse(batchResponse);
    if (batchResult != null) {
      _log.debug(
        message: 'Last batch was added with success! Committing..',
        sensitiveData: null,
      );
      await batchResult.writeBatch.commit();
      _log.info(
        message: 'Committing writeBatch done!',
        sensitiveData: null,
      );
      return TurboResponse.success(result: batchResult.documentReference);
    } else {
      _log.error(
        message: 'Last batch failed!',
        sensitiveData: null,
      );
      return const TurboResponse.fail(
        error: 'Batch operation failed',
        title: 'Batch Operation Failed',
        message: 'The last batch operation could not be completed',
      );
    }
  }

  // 🎬 DISPOSE ------------------------------------------------------------------------------- \\

  /// Releases resources held by this API instance.
  ///
  /// Subclasses override to close stream controllers and other owned
  /// resources, then chain to `super.dispose()`.
  Future<void> dispose() async {}

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Helper method to run a [Transaction] from [_firebaseFirestore]..
  Future<E> runTransaction<E>(
    TransactionHandler<E> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) => _firebaseFirestore.runTransaction(
    transactionHandler,
    timeout: timeout,
    maxAttempts: maxAttempts,
  );

  // 🔗 CROSS-MIXIN DECLARATIONS -------------------------------------------------------------- \\

  /// Gets a document reference by ID for raw data access.
  ///
  /// Declared here so that base-class helpers (e.g. [docExists]) and
  /// operation-family mixins can call it. Concrete implementation lives
  /// in [TurboFirestoreGetApi].
  DocumentReference<Map<String, dynamic>> getDocRefById({
    required String id,
    String? collectionPathOverride,
  });

  /// Gets a document reference with type conversion.
  ///
  /// Declared here so that operation-family mixins can call it.
  /// Concrete implementation lives in [TurboFirestoreGetApi].
  DocumentReference<T> getDocRefByIdWithConverter({
    required String id,
    String? collectionPathOverride,
  });

  /// Gets a collection reference for raw data access.
  ///
  /// Declared here so that operation-family mixins can call it.
  /// Concrete implementation lives in [TurboFirestoreListApi].
  Query<Map<String, dynamic>> listCollectionReference();

  /// Gets a collection reference with type conversion.
  ///
  /// Declared here so that operation-family mixins can call it.
  /// Concrete implementation lives in [TurboFirestoreListApi].
  Query<T> listCollectionReferenceWithConverter();
}

/// A powerful, type-safe wrapper around Cloud Firestore operations.
///
/// The [TFirestoreApi] provides a high-level interface for interacting with Firestore,
/// offering automatic type conversion, validation, and enhanced error handling.
///
/// Type parameter [T] represents the model type this API instance will work with.
///
/// Features:
/// - Automatic type conversion between Firestore documents and Dart objects
/// - Built-in validation through [TWriteable]
/// - Automatic timestamp management for createdAt/updatedAt fields
/// - Local ID management for easier document tracking
/// - Sensitive data handling
/// - Comprehensive logging
/// - Collection group support
/// - Batch operation capabilities
///
/// Example usage with a custom model:
/// ```dart
/// class User {
///   User({required this.name, this.age});
///
///   final String name;
///   final int? age;
///
///   factory User.fromJson(Map<String, dynamic> json) => User(
///     name: json['name'] as String,
///     age: json['age'] as int?,
///   );
///
///   Map<String, dynamic> toJson() => {
///     'name': name,
///     'age': age,
///   };
/// }
///
/// final api = TurboFirestoreApi<User>(
///   firebaseFirestore: FirebaseFirestore.instance,
///   collectionPath: () => 'users',
///   fromJson: User.fromJson,
///   toJson: (user) => user.toJson(),
/// );
///
/// // Create a new user
/// final user = User(name: 'John', age: 30);
/// await api.set(data: user);
///
/// // Query users
/// final adults = await api.query(
///   where: (ref) => ref.where('age', isGreaterThanOrEqualTo: 18),
/// );
/// ```
class TFirestoreApi<T extends TWriteable> extends _TFirestoreApiBase<T>
    with
        TurboFirestoreGetApi<T>,
        TurboFirestoreListApi<T>,
        TFirestoreCreateApi<T>,
        TFirestoreDeleteApi<T>,
        TurboFirestoreSearchApi<T>,
        TurboFirestoreStreamApi<T>,
        TFirestoreUpdateApi<T> {
  /// Creates a new instance of [TFirestoreApi].
  ///
  /// Required parameters:
  /// - [firebaseFirestore] The Firestore instance to use for operations
  /// - [collectionPath] Function that returns the path to the Firestore collection
  ///
  /// Optional parameters for type conversion:
  /// - [toJson] Converts instances of [T] to Firestore-compatible maps
  /// - [fromJson] Creates instances of [T] from Firestore documents
  /// - [fromJsonError] Alternative conversion for error cases
  ///
  /// Document ID management:
  /// - [tryAddLocalId] When true, adds document ID to local objects
  /// - [idFieldName] Field name for document ID (default: 'id')
  ///
  /// Timestamp fields:
  /// - [createdAtFieldName] Field for creation timestamp (default: 'createdAt')
  /// - [updatedAtFieldName] Field for update timestamp (default: 'updatedAt')
  ///
  /// Advanced features:
  /// - [logger] Custom logger for operation tracking
  /// - [isCollectionGroup] Enable collection group queries
  /// - [tryAddLocalDocumentReference] Add document reference to local objects
  /// - [documentReferenceFieldName] Field for document reference
  /// - [getOptions] Custom options for get operations
  /// - [TFirestoreLogger.showSensitiveData] Control sensitive data visibility in logs
  ///
  /// Example:
  /// ```dart
  /// final api = TurboFirestoreApi<User>(
  ///   firebaseFirestore: FirebaseFirestore.instance,
  ///   collectionPath: () => 'users',
  ///   fromJson: User.fromJson,
  ///   toJson: (user) => user.toJson(),
  ///   tryAddLocalId: true,
  ///   logger: CustomLogger(),
  /// );
  /// ```
  TFirestoreApi({
    required super.firebaseFirestore,
    required super.collectionPath,
    super.toJson,
    super.fromJson,
    super.fromJsonError,
    super.tryAddLocalId,
    super.logger,
    super.createdAtFieldName,
    super.updatedAtFieldName,
    super.idFieldName,
    super.documentReferenceFieldName,
    super.isCollectionGroup,
    super.tryAddLocalDocumentReference,
    super.getOptions,
    super.userIdFieldName,
    super.defaultId,
    super.unknownId,
  });
}
