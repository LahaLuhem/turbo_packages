part of 't_firestore_api.dart';

/// Extension that adds create operations to [TFirestoreApi]
///
/// Provides methods for creating and writing documents to Firestore
///
/// Features:
/// - Single document creation
/// - Batch operations
/// - Transaction support
/// - Automatic timestamp management
/// - Document merging
/// - Field-level merging
/// - Validation through [TWriteable]
///
/// Example:
/// ```dart
/// final api = TurboFirestoreApi<User>();
/// final user = User(name: 'John');
/// final response = await api.createDoc(writeable: user);
/// ```
///
/// See also:
/// [TFirestoreUpdateApi] document updates
/// [TFirestoreDeleteApi] document deletion
mixin TFirestoreCreateApi<DTO> on _TFirestoreApiBase<DTO> {
  /// Creates or writes a document to Firestore.
  ///
  /// This method provides a flexible way to create or update documents with various options
  /// for handling timestamps, batching, transactions, and merging.
  ///
  /// Parameters:
  /// - [writeable] The data to write, must implement [TWriteable]
  /// - [id] Optional custom document ID (auto-generated if not provided)
  /// - [writeBatch] Optional batch to include this operation in
  /// - [createTimeStampType] Type of timestamp to add for new documents
  /// - [updateTimeStampType] Type of timestamp to add when merging
  /// - [merge] Whether to merge with existing document
  /// - [mergeFields] Specific fields to merge (if [merge] is true)
  /// - [collectionPathOverride] Optional different collection path
  /// - [transaction] Optional transaction to include this operation in
  ///
  /// Returns a [TurboResponse] containing either:
  /// - Success with the [DocumentReference] of the created document
  /// - Failure with validation errors or operation errors
  ///
  /// Features:
  /// - Automatic validation through [TWriteable.validate]
  /// - Timestamp management based on operation type
  /// - Support for batch operations
  /// - Support for transactions
  /// - Merge/upsert capabilities
  ///
  /// Example:
  /// ```dart
  /// final user = User(name: 'John');
  /// final response = await api.createDoc(
  ///   writeable: user,
  ///   id: 'user-123',
  ///   merge: true,
  /// );
  /// response.when(
  ///   success: (ref) => print('Created user: ${ref.id}'),
  ///   fail: (error) => print('Error: $error'),
  /// );
  /// ```
  ///
  /// See also:
  /// - [createDocInBatch] for batch operations
  /// - [TTimestampType] for timestamp options
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
    _isCollectionGroup == (collectionPathOverride != null),
    'Firestore does not support finding a document by id when communicating with a collection group, '
        'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
        'in order to make this method work.',
    );
    try {
      _log.debug(
        message: 'Checking if writeable is valid..',
        sensitiveData: null,
      );
      final TurboResponse<DocumentReference>? invalidResponse = writeable
          .validate();
      if (invalidResponse != null && invalidResponse.isFail) {
        _log.warning(
          message: 'TWriteable was invalid!',
          sensitiveData: null,
        );
        return invalidResponse;
      }
      _log.info(message: 'TWriteable is valid!', sensitiveData: null);
      _log.debug(
        message: 'Creating document..',
        sensitiveData: TSensitiveData(
          path: collectionPathOverride ?? _collectionPath(),
          id: id,
          isBatch: writeBatch != null,
          createTimeStampType: createTimeStampType,
          updateTimeStampType: updateTimeStampType,
          isMerge: merge,
          mergeFields: mergeFields,
          isTransaction: transaction != null,
        ),
      );
      if (writeBatch != null) {
        _log.debug(
          message: 'WriteBatch was not null! Creating with batch..',
          sensitiveData: null,
        );
        final lastBatchResponse = await createDocInBatch(
          writeable: writeable,
          id: id,
          writeBatch: writeBatch,
          createTimeStampType: createTimeStampType,
          updateTimeStampType: updateTimeStampType,
          collectionPathOverride: collectionPathOverride,
          merge: merge,
          mergeFields: mergeFields,
        );
        _log.debug(
          message: 'Checking if batchCreate was successful..',
          sensitiveData: null,
        );
        return _handleBatchOperation(lastBatchResponse);
      } else {
        _log.debug(
          message: 'WriteBatch was null! Creating without batch..',
          sensitiveData: null,
        );
        final documentReference = id != null
            ? getDocRefById(
          id: id,
          collectionPathOverride: collectionPathOverride,
        )
            : _firebaseFirestore
            .collection(collectionPathOverride ?? _collectionPath())
            .doc();
        _log.debug(
          message: 'Creating JSON..',
          sensitiveData: null,
        );
        final json = writeable.toJson();
        final writeableAsJson =
        (merge || mergeFields != null) &&
            (await documentReference.get(_getOptions)).exists
            ? updateTimeStampType.add(
          json,
          updatedAtFieldName: _updatedAtFieldName,
          createdAtFieldName: _createdAtFieldName,
        )
            : createTimeStampType.add(
          json,
          createdAtFieldName: _createdAtFieldName,
          updatedAtFieldName: _updatedAtFieldName,
        );
        final setOptions = SetOptions(
          merge: mergeFields == null ? merge : null,
          mergeFields: mergeFields,
        );
        if (transaction == null) {
          _log.debug(
            message: 'Setting data with documentReference.set..',
            sensitiveData: TSensitiveData(
              path: collectionPathOverride ?? _collectionPath(),
              id: documentReference.id,
              data: writeableAsJson,
            ),
          );
          await documentReference.set(
            writeableAsJson,
            setOptions,
          );
        } else {
          _log.debug(
            message: 'Setting data with transaction.set..',
            sensitiveData: TSensitiveData(
              path: collectionPathOverride ?? _collectionPath(),
              id: documentReference.id,
              data: writeableAsJson,
            ),
          );
          transaction.set(
            getDocRefById(id: documentReference.id),
            writeableAsJson,
            setOptions,
          );
        }
        _log.info(
          message: 'Setting data done!',
          sensitiveData: null,
        );
        return TurboResponse.success(result: documentReference);
      }
    } catch (error, stackTrace) {
      final path = collectionPathOverride ?? _collectionPath();
      final fullPath = _buildFullPath(path, id);
      final documentData = _extractDocumentData(writeable);

      final exception = _createException(
        error: error,
        stackTrace: stackTrace,
        path: path,
        id: id,
        operationType: TOperationType.create,
        query: 'createDoc(id: $id, merge: $merge)',
        documentData: documentData,
      );

      if (transaction != null) {
        // Wrap and rethrow for transactions
        throw exception;
      }

      _log.error(
        message: 'Unable to create document',
        sensitiveData: TSensitiveData(
          path: path,
          id: id,
          operationType: TOperationType.create,
          fullPath: fullPath,
          documentData: documentData,
          isBatch: writeBatch != null,
          createTimeStampType: createTimeStampType,
          updateTimeStampType: updateTimeStampType,
          isMerge: merge,
          mergeFields: mergeFields,
          isTransaction: false,
        ),
        error: error,
        stackTrace: stackTrace,
      );

      return TurboResponse.fail(error: exception);
    }
  }

  /// Creates or writes documents using a batch operation.
  ///
  /// This method is similar to [createDoc] but specifically designed for batch operations,
  /// allowing multiple document writes to be atomic.
  ///
  /// Parameters:
  /// - [writeable] The data to write, must implement [TWriteable]
  /// - [id] Optional custom document ID (auto-generated if not provided)
  /// - [writeBatch] Optional existing batch to add to (creates new if null)
  /// - [createTimeStampType] Type of timestamp to add for new documents
  /// - [updateTimeStampType] Type of timestamp to add when merging
  /// - [merge] Whether to merge with existing document
  /// - [mergeFields]: Specific fields to merge (if [merge] is true)
  /// - [collectionPathOverride]: Optional different collection path
  ///
  /// Returns a [TurboResponse] containing either:
  /// - Success with [TWriteBatchWithReference] containing the batch and document reference
  /// - Failure with validation errors or operation errors
  ///
  /// Features:
  /// - Automatic validation through [TWriteable.validate]
  /// - Timestamp management based on operation type
  /// - Creates new batch if none provided
  /// - Merge/upsert capabilities
  ///
  /// Example:
  /// ```dart
  /// final batch = firestore.batch();
  /// final user = User(name: 'John');
  ///
  /// final response = await api.createDocInBatch(
  ///   writeable: user,
  ///   writeBatch: batch,
  ///   merge: true,
  /// );
  ///
  /// response.when(
  ///   success: (result) async {
  ///     await result.writeBatch.commit();
  ///     print('Created user: ${result.documentReference.id}');
  ///   },
  ///   fail: (error) => print('Error: $error'),
  /// );
  /// ```
  ///
  /// Note: The batch must be committed manually after all operations are added.
  ///
  /// See also:
  /// - [createDoc] for single document operations
  /// - [TWriteBatchWithReference] for batch result structure
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
    _isCollectionGroup == (collectionPathOverride != null),
    'Firestore does not support finding a document by id when communicating with a collection group, '
        'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
        'in order to make this method work.',
    );
    try {
      final TurboResponse<TWriteBatchWithReference<Map<String, dynamic>>>?
      invalidResponse = writeable.validate();
      if (invalidResponse != null && invalidResponse.isFail) {
        _log.warning(
          message: 'TWriteable was invalid!',
          sensitiveData: null,
        );
        return invalidResponse;
      }
      _log.info(message: 'TWriteable is valid!', sensitiveData: null);
      _log.debug(
        message: 'Creating document with batch..',
        sensitiveData: TSensitiveData(
          path: collectionPathOverride ?? _collectionPath(),
          id: id,
          isBatch: writeBatch != null,
          createTimeStampType: createTimeStampType,
          updateTimeStampType: updateTimeStampType,
          isMerge: merge,
          mergeFields: mergeFields,
        ),
      );
      final nullSafeWriteBatch = writeBatch ?? this.writeBatch;
      final documentReference = id != null
          ? getDocRefById(
        id: id,
        collectionPathOverride: collectionPathOverride,
      )
          : _firebaseFirestore
          .collection(collectionPathOverride ?? _collectionPath())
          .doc();
      _log.debug(message: 'Creating JSON..', sensitiveData: null);
      final json = writeable.toJson();
      final writeableAsJson =
      (merge || mergeFields != null) &&
          (await documentReference.get(_getOptions)).exists
          ? updateTimeStampType.add(
        json,
        updatedAtFieldName: _updatedAtFieldName,
        createdAtFieldName: _createdAtFieldName,
      )
          : createTimeStampType.add(
        json,
        createdAtFieldName: _createdAtFieldName,
        updatedAtFieldName: _updatedAtFieldName,
      );
      _log.debug(
        message: 'Setting data with writeBatch.set..',
        sensitiveData: TSensitiveData(
          path: collectionPathOverride ?? _collectionPath(),
          id: documentReference.id,
          data: writeableAsJson,
        ),
      );
      nullSafeWriteBatch.set(
        documentReference,
        writeableAsJson,
        SetOptions(
          merge: mergeFields == null ? merge : null,
          mergeFields: mergeFields,
        ),
      );
      _log.info(
        message:
        'Adding create to batch done! Returning WriteBatchWithReference..',
        sensitiveData: null,
      );
      return TurboResponse.success(
        result: TWriteBatchWithReference(
          writeBatch: nullSafeWriteBatch,
          documentReference: documentReference,
        ),
      );
    } catch (error, stackTrace) {
      final path = collectionPathOverride ?? _collectionPath();
      final fullPath = _buildFullPath(path, id);
      final documentData = _extractDocumentData(writeable);

      final exception = _createException(
        error: error,
        stackTrace: stackTrace,
        path: path,
        id: id,
        operationType: TOperationType.create,
        query: 'createDocInBatch(id: $id, merge: $merge)',
        documentData: documentData,
      );

      _log.error(
        message: 'Unable to create document with batch',
        sensitiveData: TSensitiveData(
          path: path,
          id: id,
          operationType: TOperationType.create,
          fullPath: fullPath,
          documentData: documentData,
          isBatch: writeBatch != null,
          createTimeStampType: createTimeStampType,
          updateTimeStampType: updateTimeStampType,
          isMerge: merge,
          mergeFields: mergeFields,
        ),
        error: error,
        stackTrace: stackTrace,
      );

      return TurboResponse.fail(error: exception);
    }
  }
}
