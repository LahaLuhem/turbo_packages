part of 't_firestore_api.dart';

/// Extension that adds read/get operations to [TFirestoreApi]
///
/// This extension provides methods for retrieving documents from Firestore
///
/// Features:
/// - Single document retrieval
/// - Type-safe document conversion
/// - Document reference access
/// - Local ID and reference field management
/// - Collection group queries
/// - Custom collection path overrides
///
/// Example:
/// ```dart
/// final api = TurboFirestoreApi<User>();
/// final response = await api.getById(id: 'user-123');
/// ```
///
/// See also:
/// - [TFirestoreCreateApi] document creation and updates
/// - [TFirestoreDeleteApi] document deletion
mixin TurboFirestoreGetApi<T> on _TFirestoreApiBase<T> {
  /// Retrieves a document by its unique identifier
  ///
  /// Returns raw Firestore data without type conversion. Useful for direct data access
  /// or when type conversion is not needed
  ///
  /// Parameters:
  /// [id] unique identifier of the document
  /// [collectionPathOverride] override path for collection groups
  ///
  /// Returns [TurboResponse] containing:
  /// - Success with document data
  /// - Empty fail when document not found
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
  /// final response = await api.getById(id: 'user-123');
  /// response.when(
  ///   success: (data) => print('Found user ${data['name']}'),
  ///   fail: (error) => print('Error $error'),
  /// );
  /// ```
  ///
  /// See also:
  /// - [getByIdWithConverter] type-safe document retrieval
  /// - [getDocRefById] document reference access
  Future<TurboResponse<Map<String, dynamic>>> getById({
    required String id,
    String? collectionPathOverride,
    bool tryCache = true,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    try {
      _log.debug(
        message: 'Finding without converter..',
        sensitiveData: TSensitiveData(
          path: _pPath(collectionPathOverride),
          id: id,
        ),
      );

      if (tryCache) {
        final cachedResult = await _firestoreCache?.get(
          path: _pPath(collectionPathOverride),
          id: id,
        );
        if (cachedResult != null) {
          _log.info(
            message: 'Found item in cache!',
          );
          return TurboResponse.success(result: cachedResult);
        }
      }

      final result = (await getDocRefById(
        id: id,
        collectionPathOverride: collectionPathOverride,
      ).get(_getOptions)).data();
      if (result != null) {
        _log.info(
          message: 'Found item!',
          sensitiveData: null,
        );
        if (_firestoreCache != null) {
          unawaited(
            _firestoreCache.saveDoc(
              docId: id,
              path: _pPath(collectionPathOverride),
              doc: result,
            ),
          );
        }
        return TurboResponse.success(result: result);
      } else {
        _log.warning(
          message: 'Found nothing!',
          sensitiveData: null,
        );
        return const TurboResponse.fail(
          error: 'Document not found',
          title: 'Not Found',
          message: 'The requested document was not found',
        );
      }
    } catch (error, stackTrace) {
      final path = _pPath(collectionPathOverride);
      final fullPath = _buildFullPath(path, id);

      final exception = _createException(
        error: error,
        stackTrace: stackTrace,
        path: path,
        id: id,
        operationType: TOperationType.read,
        query: 'getById(id: $id)',
      );

      _log.error(
        message: 'Unable to find document',
        sensitiveData: TSensitiveData(
          path: path,
          id: id,
          operationType: TOperationType.read,
          fullPath: fullPath,
        ),
        error: error,
        stackTrace: stackTrace,
      );

      return TurboResponse.fail(error: exception);
    }
  }

  /// Retrieves and converts a document by its unique identifier
  ///
  /// Returns document data converted to type [T] using [_fromJson]
  /// Provides type-safe access to Firestore data
  ///
  /// Parameters:
  /// [id] unique identifier of the document
  /// [collectionPathOverride] override path for collection groups
  ///
  /// Returns [TurboResponse] containing:
  /// - Success with typed document data
  /// - Empty fail when document not found
  /// - Fail with error details on operation failure
  ///
  /// Features:
  /// - Automatic type conversion
  /// - Local ID field management
  /// - Document reference handling
  /// - Type-safe error handling
  /// - Error logging
  ///
  /// Example:
  /// ```dart
  /// final response = await api.getByIdWithConverter(id: 'user-123');
  /// response.when(
  ///   success: (user) => print('Found user ${user.name}'),
  ///   fail: (error) => print('Error $error'),
  /// );
  /// ```
  ///
  /// See also:
  /// - [getById] raw data access
  /// - [getDocRefByIdWithConverter] typed document reference
  Future<TurboResponse<T>> getByIdWithConverter({
    required String id,
    String? collectionPathOverride,
    bool tryCache = true,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    try {
      _log.debug(
        message: 'Finding with converter..',
        sensitiveData: TSensitiveData(
          path: _pPath(collectionPathOverride),
          id: id,
        ),
      );

      if (tryCache && _fromJson != null) {
        final cachedResult = await _firestoreCache?.get(
          path: _pPath(collectionPathOverride),
          id: id,
        );
        if (cachedResult != null) {
          final parsedCachedResult = _fromJson.call(cachedResult);
          if (parsedCachedResult != null) {
            _log.info(
              message: 'Found item in cache!',
            );
            return TurboResponse.success(result: parsedCachedResult);
          }
        }
      }

      final result = (await getDocRefByIdWithConverter(
        id: id,
        collectionPathOverride: collectionPathOverride,
      ).get(_getOptions)).data();
      if (result != null) {
        _log.info(
          message: 'Found item!',
          sensitiveData: null,
        );
        // #FEEDBACK #TODO 2026-04-27T17:38:39.013+02:00 | Remove withConverter methods and convert self - saving cache before the convertion
        if (_firestoreCache != null && _toJson != null) {
          unawaited(
            _firestoreCache.saveDoc(
              doc: _toJson(result),
              docId: id,
              path: _pPath(collectionPathOverride),
            ),
          );
        }
        return TurboResponse.success(result: result);
      } else {
        _log.warning(
          message: 'Found nothing!',
          sensitiveData: null,
        );
        return TurboResponse.fail(
          error: 'Document not found',
          title: 'Not Found',
          message: 'The requested document was not found',
        );
      }
    } catch (error, stackTrace) {
      final path = _pPath(collectionPathOverride);
      final fullPath = _buildFullPath(path, id);

      final exception = _createException(
        error: error,
        stackTrace: stackTrace,
        path: path,
        id: id,
        operationType: TOperationType.read,
        query: 'getByIdWithConverter(id: $id)',
      );

      _log.error(
        message: 'Unable to find document',
        error: error,
        stackTrace: stackTrace,
        sensitiveData: TSensitiveData(
          path: path,
          id: id,
          operationType: TOperationType.read,
          fullPath: fullPath,
        ),
      );

      return TurboResponse.fail(error: exception);
    }
  }

  /// Gets a document reference by ID for raw data access
  ///
  /// Returns [DocumentReference] for Firestore operations
  /// Includes converters for field management
  ///
  /// Parameters:
  /// [id] unique identifier of the document
  /// [collectionPathOverride] override path for collection groups
  ///
  /// Features:
  /// - Raw data access
  /// - Local ID field management
  /// - Document reference handling
  /// - Automatic field cleanup
  ///
  /// Example:
  /// ```dart
  /// final docRef = api.getDocRefById(id: 'user-123');
  /// final snapshot = await docRef.get();
  /// if (snapshot.exists) {
  ///   print('User data ${snapshot.data()}');
  /// }
  /// ```
  ///
  /// See also:
  /// - [getDocRefByIdWithConverter] type-safe references
  /// - [getById] direct data access
  @override
  DocumentReference<Map<String, dynamic>> getDocRefById({
    required String id,
    String? collectionPathOverride,
  }) {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    _log.debug(
      message: 'Finding document..',
      sensitiveData: TSensitiveData(
        path: _pPath(collectionPathOverride),
        id: id,
      ),
    );
    return _firebaseFirestore
        .doc('${_pPath(collectionPathOverride)}/$id')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data() ?? {};
            try {
              return data
                  .tryAddLocalId(
                    snapshot.id,
                    idFieldName: _idFieldName,
                    tryAddLocalId: _tryAddLocalId,
                  )
                  .tryAddLocalDocumentReference(
                    snapshot.reference,
                    referenceFieldName: _documentReferenceFieldName,
                    tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
                  );
            } catch (error) {
              _log.error(
                message: 'Unexpected error caught while adding local id and document reference',
                sensitiveData: TSensitiveData(
                  path: _pPath(collectionPathOverride),
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
                  .tryRemoveLocalId(
                    idFieldName: _idFieldName,
                    tryRemoveLocalId: _tryAddLocalId,
                  )
                  .tryRemoveLocalDocumentReference(
                    referenceFieldName: _documentReferenceFieldName,
                    tryRemoveLocalDocumentReference: _tryAddLocalDocumentReference,
                  );
            } catch (error) {
              _log.error(
                message: 'Unexpected error caught while removing local id and document reference',
                sensitiveData: TSensitiveData(
                  path: _pPath(collectionPathOverride),
                  id: id,
                  data: data,
                ),
              );
              rethrow;
            }
          },
        );
  }

  /// Gets a document reference with type conversion
  ///
  /// Returns [DocumentReference] with automatic conversion between Firestore and [T]
  /// Requires [_fromJson] and [_toJson] configuration
  ///
  /// Parameters:
  /// [id] unique identifier of the document
  /// [collectionPathOverride] override path for collection groups
  ///
  /// Features:
  /// - Automatic type conversion
  /// - Local ID field management
  /// - Document reference handling
  /// - Type-safe operations
  ///
  /// Example:
  /// ```dart
  /// final docRef = api.getDocRefByIdWithConverter<User>(id: 'user-123');
  /// final snapshot = await docRef.get();
  /// if (snapshot.exists) {
  ///   final user = snapshot.data();
  ///   print('User name ${user.name}');
  /// }
  /// ```
  ///
  /// See also:
  /// - [getDocRefById] raw data references
  /// - [getByIdWithConverter] direct typed access
  @override
  DocumentReference<T> getDocRefByIdWithConverter({
    required String id,
    String? collectionPathOverride,
  }) {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    _log.debug(
      message: 'Finding document with converter..',
      sensitiveData: TSensitiveData(
        path: _pPath(collectionPathOverride),
        id: id,
      ),
    );
    return _firebaseFirestore
        .doc('${_pPath(collectionPathOverride)}/$id')
        .withConverter<T>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data() ?? {};
            try {
              return _fromJson!(
                data
                    .tryAddLocalId(
                      snapshot.id,
                      idFieldName: _idFieldName,
                      tryAddLocalId: _tryAddLocalId,
                    )
                    .tryAddLocalDocumentReference(
                      snapshot.reference,
                      referenceFieldName: _documentReferenceFieldName,
                      tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
                    ),
              );
            } catch (error, stackTrace) {
              _log.error(
                message: 'Unexpected error caught while adding local id and document reference',
                sensitiveData: TSensitiveData(
                  path: _pPath(collectionPathOverride),
                  id: snapshot.id,
                  data: data,
                ),
                error: InvalidJsonException(
                  id: snapshot.id,
                  path: snapshot.reference.path,
                  api: runtimeType.toString(),
                  data: data,
                ),
                stackTrace: stackTrace,
              );
              try {
                return _fromJsonError!(
                  data
                      .tryAddLocalId(
                        snapshot.id,
                        idFieldName: _idFieldName,
                        tryAddLocalId: _tryAddLocalId,
                      )
                      .tryAddLocalDocumentReference(
                        snapshot.reference,
                        referenceFieldName: _documentReferenceFieldName,
                        tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
                      ),
                );
              } catch (error, stackTrace) {
                _log.error(
                  message: 'Unexpected error caught while adding local id and document reference',
                  sensitiveData: TSensitiveData(
                    path: _pPath(collectionPathOverride),
                    id: snapshot.id,
                    data: data,
                  ),
                  error: error,
                  stackTrace: stackTrace,
                );
                rethrow;
              }
            }
          },
          toFirestore: (data, _) {
            try {
              return _toJson!(data)
                  .tryRemoveLocalId(
                    idFieldName: _idFieldName,
                    tryRemoveLocalId: _tryAddLocalId,
                  )
                  .tryRemoveLocalDocumentReference(
                    referenceFieldName: _documentReferenceFieldName,
                    tryRemoveLocalDocumentReference: _tryAddLocalDocumentReference,
                  );
            } catch (error) {
              _log.error(
                message: 'Unexpected error caught while removing local id and document reference',
                sensitiveData: TSensitiveData(
                  path: _pPath(collectionPathOverride),
                  id: id,
                  data: data,
                ),
              );
              rethrow;
            }
          },
        );
  }

  /// Gets a document snapshot for raw data access
  ///
  /// Returns [DocumentSnapshot] containing raw document data and metadata
  /// Useful for accessing document metadata with data
  ///
  /// Parameters:
  /// [id] unique identifier of the document
  /// [collectionPathOverride] override path for collection groups
  ///
  /// Features:
  /// - Metadata access
  /// - Raw data access
  /// - Local ID field management
  /// - Document reference handling
  ///
  /// Example:
  /// ```dart
  /// final snapshot = await api.getDocSnapshotById(id: 'user-123');
  /// if (snapshot.exists) {
  ///   print('Created at ${snapshot.metadata.creationTime}');
  ///   print('Data ${snapshot.data()}');
  /// }
  /// ```
  ///
  /// See also:
  /// - [getDocSnapshotByIdWithConverter] typed snapshots
  /// - [getDocRefById] reference access
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocSnapshotById({
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
      message: 'Finding document snapshot..',
      sensitiveData: TSensitiveData(
        path: _pPath(collectionPathOverride),
        id: id,
      ),
    );
    return docRef.get(_getOptions);
  }

  /// Gets a document snapshot with type conversion
  ///
  /// Returns [DocumentSnapshot] with automatic conversion to type [T]
  /// Useful for accessing metadata with typed data
  ///
  /// Parameters:
  /// [id] unique identifier of the document
  /// [collectionPathOverride] override path for collection groups
  ///
  /// Features:
  /// - Automatic type conversion
  /// - Metadata access
  /// - Local ID field management
  /// - Document reference handling
  ///
  /// Example:
  /// ```dart
  /// final snapshot = await api.getDocSnapshotByIdWithConverter<User>(id: 'user-123');
  /// if (snapshot.exists) {
  ///   final user = snapshot.data();
  ///   print('Created at ${snapshot.metadata.creationTime}');
  ///   print('User name ${user.name}');
  /// }
  /// ```
  ///
  /// See also:
  /// - [getDocSnapshotById] raw data snapshots
  /// - [getDocRefByIdWithConverter] reference access
  Future<DocumentSnapshot<T>> getDocSnapshotByIdWithConverter({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    final docRefWithConverter = getDocRefByIdWithConverter(
      id: id,
      collectionPathOverride: collectionPathOverride,
    );
    _log.debug(
      message: 'Finding doc snapshot with converter..',
      sensitiveData: TSensitiveData(
        path: _pPath(collectionPathOverride),
        id: id,
      ),
    );
    return docRefWithConverter.get(_getOptions);
  }
}
