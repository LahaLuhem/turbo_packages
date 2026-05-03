part of 't_firestore_api.dart';

/// Extension that adds list operations to [TFirestoreApi]
///
/// Provides methods for retrieving multiple documents from Firestore
///
/// Features:
/// - Query-based document retrieval
/// - Type-safe document conversion
/// - Collection reference access
/// - Local ID and reference field management
/// - Collection group queries
/// - Custom query support
///
/// Example:
/// ```dart
/// final api = TurboFirestoreApi<User>();
/// final response = await api.listAll();
/// ```
///
/// See also:
/// [TurboFirestoreGetApi] single document retrieval
/// [TurboFirestoreSearchApi] search operations
mixin TurboFirestoreListApi<DTO> on _TFirestoreApiBase<DTO> {
  /// Lists documents matching a custom query
  ///
  /// Returns raw Firestore data without type conversion
  /// Useful for complex queries with raw data access
  ///
  /// Parameters:
  /// [collectionReferenceQuery] custom query to filter documents
  /// [whereDescription] description of the query for logging
  ///
  /// Returns [TurboResponse] containing:
  /// - Success with list of document data
  /// - Fail with error details on operation failure
  ///
  /// Features:
  /// - Custom query support
  /// - Raw data access
  /// - Local ID field management
  /// - Error logging
  ///
  /// Example:
  /// ```dart
  /// final response = await api.listByQuery(
  ///   collectionReferenceQuery: (ref) => ref.where('age', isGreaterThan: 18),
  ///   whereDescription: 'Finding adult users',
  /// );
  /// response.when(
  ///   success: (users) => print('Found ${users.length} adults'),
  ///   fail: (error) => print('Error $error'),
  /// );
  /// ```
  ///
  /// See also:
  /// [listByQueryWithConverter] type-safe queries
  /// [listAll] retrieve all documents
  Future<TurboResponse<List<Map<String, dynamic>>>> listByQuery({
    required CollectionReferenceDef<Map<String, dynamic>>
    collectionReferenceQuery,
    required String whereDescription,
    bool tryCache = true,
    bool forceCacheRefresh = false,
  }) async {
    try {
      _log.debug(
        message: 'Finding without converter, with custom query..',
        sensitiveData: TSensitiveData(
          path: _collectionPath(),
          whereDescription: whereDescription,
        ),
      );

      if (tryCache ||
          forceCacheRefresh ||
          (_firestoreCache?.forceCacheRefresh ?? false)) {
        final cachedResults = await _firestoreCache?.list(
          path: _collectionPath(),
          query: whereDescription,
          forceCacheRefresh: forceCacheRefresh,
        );
        if (cachedResults != null) {
          _log.info(
            message: 'Found items in cache!',
          );
          return TurboResponse.success(result: cachedResults);
        }
      }

      final result =
          (await collectionReferenceQuery(
                listCollectionReference(),
              ).get(_getOptions)).docs
              .map(
                (e) => e.data(),
              )
              .toList();

      if (result.isNotEmpty && _firestoreCache != null) {
        unawaited(
          _firestoreCache.saveDocs(
            query: whereDescription,
            path: _collectionPath(),
            docs: result,
          ),
        );
      }

      _logResultLength(result);
      return TurboResponse.success(result: result);
    } catch (error, stackTrace) {
      final path = _collectionPath();
      final exception = _createException(
        error: error,
        stackTrace: stackTrace,
        path: path,
        query: whereDescription,
        operationType: TOperationType.read,
      );

      _log.error(
        message: 'Unable to find documents with custom query',
        sensitiveData: TSensitiveData(
          path: path,
          whereDescription: whereDescription,
          operationType: TOperationType.read,
          fullPath: path,
        ),
        error: error,
        stackTrace: stackTrace,
      );

      return TurboResponse.fail(error: exception);
    }
  }

  /// Lists and converts documents matching a custom query
  ///
  /// Returns documents converted to type [DTO] using [_fromJson]
  /// Provides type-safe access to filtered Firestore data
  ///
  /// Parameters:
  /// [collectionReferenceQuery] custom query to filter documents
  /// [whereDescription] description of the query for logging
  ///
  /// Returns [TurboResponse] containing:
  /// - Success with list of typed documents
  /// - Fail with error details on operation failure
  ///
  /// Features:
  /// - Custom query support
  /// - Automatic type conversion
  /// - Local ID field management
  /// - Document reference handling
  /// - Error logging
  ///
  /// Example:
  /// ```dart
  /// final response = await api.listByQueryWithConverter(
  ///   collectionReferenceQuery: (ref) => ref.where('age', isGreaterThan: 18),
  ///   whereDescription: 'Finding adult users',
  /// );
  /// response.when(
  ///   success: (users) => print('Found ${users.length} adults'),
  ///   fail: (error) => print('Error $error'),
  /// );
  /// ```
  ///
  /// See also:
  /// [listByQuery] raw data queries
  /// [listAllWithConverter] retrieve all typed documents
  Future<TurboResponse<List<DTO>>> listByQueryWithConverter({
    required CollectionReferenceDef<DTO> collectionReferenceQuery,
    required String whereDescription,
    bool tryCache = true,
    bool forceCacheRefresh = false,
  }) async {
    try {
      _log.debug(
        message: 'Finding with converter, with custom query..',
        sensitiveData: TSensitiveData(
          path: _collectionPath(),
          whereDescription: whereDescription,
        ),
      );

      if ((tryCache ||
              forceCacheRefresh ||
              (_firestoreCache?.forceCacheRefresh ?? false)) &&
          _fromJson != null) {
        final cachedResults = await _firestoreCache?.list(
          path: _collectionPath(),
          query: whereDescription,
          forceCacheRefresh: forceCacheRefresh,
        );
        if (cachedResults != null) {
          _log.info(
            message: 'Found items in cache!',
          );
          final parsedResults = <DTO>[];
          for (final doc in cachedResults) {
            parsedResults.add(_fromJson.call(doc));
          }
          return TurboResponse.success(result: parsedResults);
        }
      }

      final result = (await collectionReferenceQuery(
        listCollectionReferenceWithConverter(),
      ).get(_getOptions)).docs.map((e) => e.data()).toList();

      if (_firestoreCache != null && _toJson != null) {
        unawaited(
          _firestoreCache.saveDocs(
            query: whereDescription,
            path: _collectionPath(),
            docs: result.map((e) => _toJson(e)).toList(),
          ),
        );
      }

      _logResultLength(result);
      return TurboResponse.success(result: result);
    } catch (error, stackTrace) {
      final path = _collectionPath();
      final exception = _createException(
        error: error,
        stackTrace: stackTrace,
        path: path,
        query: whereDescription,
        operationType: TOperationType.read,
      );

      _log.error(
        message: 'Unable to find documents with custom query',
        sensitiveData: TSensitiveData(
          path: path,
          whereDescription: whereDescription,
          operationType: TOperationType.read,
          fullPath: path,
        ),
        error: error,
        stackTrace: stackTrace,
      );

      return TurboResponse.fail(error: exception);
    }
  }

  /// Lists all documents in the collection
  ///
  /// Returns raw Firestore data without type conversion
  /// Useful for bulk data access or when type conversion is not needed
  ///
  /// Returns [TurboResponse] containing:
  /// - Success with list of document data
  /// - Fail with error details on operation failure
  ///
  /// Features:
  /// - Raw data access
  /// - Local ID field management
  /// - Document reference handling
  /// - Error logging
  ///
  /// Example:
  /// ```dart
  /// final response = await api.listAll();
  /// response.when(
  ///   success: (users) => print('Found ${users.length} users'),
  ///   fail: (error) => print('Error $error'),
  /// );
  /// ```
  ///
  /// See also:
  /// [listAllWithConverter] type-safe retrieval
  /// [listByQuery] filtered queries
  Future<TurboResponse<List<Map<String, dynamic>>>> listAll({
    bool tryCache = true,
    bool forceCacheRefresh = false,
  }) async {
    try {
      _log.debug(
        message: 'Finding all documents without converter..',
        sensitiveData: TSensitiveData(
          path: _collectionPath(),
        ),
      );

      if (tryCache) {
        final cachedResults = await _firestoreCache?.list(
          path: _collectionPath(),
          query: 'all',
        );
        if (cachedResults != null) {
          _log.info(
            message: 'Found items in cache!',
          );
          return TurboResponse.success(result: cachedResults);
        }
      }

      final result = (await listCollectionReference().get(_getOptions)).docs
          .map(
            (e) => e.data(),
          )
          .toList();

      if (result.isNotEmpty && _firestoreCache != null) {
        unawaited(
          _firestoreCache.saveDocs(
            query: 'all',
            path: _collectionPath(),
            docs: result,
          ),
        );
      }

      _logResultLength(result);
      return TurboResponse.success(result: result);
    } catch (error, stackTrace) {
      final path = _collectionPath();
      final exception = _createException(
        error: error,
        stackTrace: stackTrace,
        path: path,
        query: 'listAll()',
        operationType: TOperationType.read,
      );

      _log.error(
        message: 'Unable to find all documents',
        sensitiveData: TSensitiveData(
          path: path,
          operationType: TOperationType.read,
          fullPath: path,
        ),
        error: error,
        stackTrace: stackTrace,
      );

      return TurboResponse.fail(error: exception);
    }
  }

  /// Lists and converts all documents in the collection
  ///
  /// Returns documents converted to type [DTO] using [_fromJson]
  /// Provides type-safe access to all collection data
  ///
  /// Returns [TurboResponse] containing:
  /// - Success with list of typed documents
  /// - Fail with error details on operation failure
  ///
  /// Features:
  /// - Automatic type conversion
  /// - Local ID field management
  /// - Document reference handling
  /// - Error logging
  ///
  /// Example:
  /// ```dart
  /// final response = await api.listAllWithConverter();
  /// response.when(
  ///   success: (users) => print('Found ${users.length} users'),
  ///   fail: (error) => print('Error $error'),
  /// );
  /// ```
  ///
  /// See also:
  /// [listAll] raw data access
  /// [listByQueryWithConverter] filtered type-safe queries
  Future<TurboResponse<List<DTO>>> listAllWithConverter({
    bool tryCache = true,
    bool forceCacheRefresh = false,
  }) async {
    try {
      _log.debug(
        message: 'Finding all documents with converter..',
        sensitiveData: TSensitiveData(
          path: _collectionPath(),
        ),
      );

      if (tryCache ||
          forceCacheRefresh ||
          (_firestoreCache?.forceCacheRefresh ?? false)) {
        final cachedResults = await _firestoreCache?.list(
          path: _collectionPath(),
          query: 'all',
          forceCacheRefresh: forceCacheRefresh,
        );
        if (cachedResults != null && _fromJson != null) {
          _log.info(
            message: 'Found items in cache!',
          );
          return TurboResponse.success(
            result: cachedResults.map((e) => _fromJson.call(e)).toList(),
          );
        }
      }

      final result = (await listCollectionReferenceWithConverter().get(
        _getOptions,
      )).docs.map((e) => e.data()).toList();

      if (result.isNotEmpty && _firestoreCache != null && _toJson != null) {
        unawaited(
          _firestoreCache.saveDocs(
            query: 'all',
            path: _collectionPath(),
            docs: result.map((e) => _toJson(e)).toList(),
          ),
        );
      }

      _logResultLength(result);
      return TurboResponse.success(result: result);
    } catch (error, stackTrace) {
      final path = _collectionPath();
      final exception = _createException(
        error: error,
        stackTrace: stackTrace,
        path: path,
        query: 'listAllWithConverter()',
        operationType: TOperationType.read,
      );

      _log.error(
        message: 'Unable to find all documents',
        sensitiveData: TSensitiveData(
          path: path,
          operationType: TOperationType.read,
          fullPath: path,
        ),
        error: error,
        stackTrace: stackTrace,
      );

      return TurboResponse.fail(error: exception);
    }
  }

  /// Gets a collection reference for raw data access
  ///
  /// Returns [Query] for raw Firestore operations
  /// Includes converters for field management
  ///
  /// Features:
  /// - Raw data access
  /// - Local ID field management
  /// - Document reference handling
  /// - Collection group support
  ///
  /// Example:
  /// ```dart
  /// final ref = api.listCollectionReference();
  /// final snapshot = await ref.where('age', isGreaterThan: 18).get();
  /// print('Found ${snapshot.docs.length} adults');
  /// ```
  ///
  /// See also:
  /// [listCollectionReferenceWithConverter] type-safe references
  /// [listByQuery] direct query access
  @override
  Query<Map<String, dynamic>> listCollectionReference() {
    _log.debug(
      message: 'Finding collection..',
      sensitiveData: TSensitiveData(
        path: _collectionPath(),
      ),
    );
    return (_isCollectionGroup
            ? _firebaseFirestore.collectionGroup(_collectionPath())
            : _firebaseFirestore.collection(_collectionPath()))
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data() ?? {};
            try {
              return data
                  .tryAddLocalId<String, dynamic>(
                    snapshot.id,
                    idFieldName: _idFieldName,
                    tryAddLocalId: _tryAddLocalId,
                  )
                  .tryAddLocalDocumentReference<String, dynamic>(
                    snapshot.reference,
                    referenceFieldName: _documentReferenceFieldName,
                    tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
                  );
            } catch (error) {
              _log.error(
                message:
                    'Unexpected error caught while adding local id and document reference',
                sensitiveData: TSensitiveData(
                  path: _collectionPath(),
                  id: snapshot.id,
                  data: data,
                ),
              );
              rethrow;
            }
          },
          toFirestore: (data, _) {
            try {
              return data
                  .tryRemoveLocalId<String, dynamic>(
                    idFieldName: _idFieldName,
                    tryRemoveLocalId: _tryAddLocalId,
                  )
                  .tryRemoveLocalDocumentReference<String, dynamic>(
                    referenceFieldName: _documentReferenceFieldName,
                    tryRemoveLocalDocumentReference:
                        _tryAddLocalDocumentReference,
                  );
            } catch (error) {
              _log.error(
                message: 'Could not find collection',
                sensitiveData: TSensitiveData(
                  path: _collectionPath(),
                ),
              );
              rethrow;
            }
          },
        );
  }

  /// Gets a collection reference with type conversion
  ///
  /// Returns [Query] with automatic conversion between Firestore and [DTO]
  /// Requires [_fromJson] and [_toJson] configuration
  ///
  /// Features:
  /// - Automatic type conversion
  /// - Local ID field management
  /// - Document reference handling
  /// - Collection group support
  /// - Error handling with [_fromJsonError]
  ///
  /// Example:
  /// ```dart
  /// final ref = api.listCollectionReferenceWithConverter<User>();
  /// final snapshot = await ref.where('age', isGreaterThan: 18).get();
  /// final users = snapshot.docs.map((doc) => doc.data()).toList();
  /// print('Found ${users.length} adult users');
  /// ```
  ///
  /// See also:
  /// [listCollectionReference] raw data references
  /// [listByQueryWithConverter] direct type-safe queries
  @override
  Query<DTO> listCollectionReferenceWithConverter() {
    _log.debug(
      message: 'Finding collection with converter..',
      sensitiveData: TSensitiveData(
        path: _collectionPath(),
      ),
    );
    return (_isCollectionGroup
            ? _firebaseFirestore.collectionGroup(_collectionPath())
            : _firebaseFirestore.collection(_collectionPath()))
        .withConverter<DTO>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data() ?? {};
            try {
              return _fromJson!(
                data
                    .tryAddLocalId<String, dynamic>(
                      snapshot.id,
                      idFieldName: _idFieldName,
                      tryAddLocalId: _tryAddLocalId,
                    )
                    .tryAddLocalDocumentReference<String, dynamic>(
                      snapshot.reference,
                      referenceFieldName: _documentReferenceFieldName,
                      tryAddLocalDocumentReference:
                          _tryAddLocalDocumentReference,
                    ),
              );
            } catch (error, stackTrace) {
              _log.error(
                message:
                    'Unexpected error caught while adding local id and document reference',
                sensitiveData: TSensitiveData(
                  path: _collectionPath(),
                  id: snapshot.id,
                  data: data,
                ),
                stackTrace: stackTrace,
                error: InvalidJsonException(
                  id: snapshot.id,
                  path: snapshot.reference.path,
                  api: runtimeType.toString(),
                  data: data,
                ),
              );
              _log.debug(
                message: 'Returning error response..',
                sensitiveData: null,
              );
              try {
                return _fromJsonError!(
                  data
                      .tryAddLocalId<String, dynamic>(
                        snapshot.id,
                        idFieldName: _idFieldName,
                        tryAddLocalId: _tryAddLocalId,
                      )
                      .tryAddLocalDocumentReference<String, dynamic>(
                        snapshot.reference,
                        referenceFieldName: _documentReferenceFieldName,
                        tryAddLocalDocumentReference:
                            _tryAddLocalDocumentReference,
                      ),
                );
              } catch (error, stackTrace) {
                _log.error(
                  message:
                      'Unexpected error caught while adding local id and document reference',
                  sensitiveData: TSensitiveData(
                    path: _collectionPath(),
                    id: snapshot.id,
                    data: data,
                  ),
                  error: error,
                  stackTrace: stackTrace,
                );
              }
              rethrow;
            }
          },
          toFirestore: (data, _) {
            try {
              return _toJson!(data)
                  .tryRemoveLocalId<String, dynamic>(
                    idFieldName: _idFieldName,
                    tryRemoveLocalId: _tryAddLocalId,
                  )
                  .tryRemoveLocalDocumentReference<String, dynamic>(
                    referenceFieldName: _documentReferenceFieldName,
                    tryRemoveLocalDocumentReference:
                        _tryAddLocalDocumentReference,
                  );
            } catch (error) {
              _log.error(
                message:
                    'Unexpected error caught while removing local id and document reference',
                sensitiveData: TSensitiveData(
                  path: _collectionPath(),
                  data: data,
                ),
              );
              rethrow;
            }
          },
        );
  }
}
