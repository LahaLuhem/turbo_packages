/// A powerful and flexible Firestore API wrapper for Flutter applications
///
/// This package provides a type-safe, feature-rich interface for interacting with Cloud Firestore
/// It includes support for CRUD operations, real-time updates, batch operations, and more
///
/// Features:
/// - Type-safe document operations
/// - Real-time data streaming
/// - Batch and transaction support
/// - Automatic timestamp management
/// - Search capabilities
/// - Collection group queries
/// - Error handling and logging
/// - Optimistic updates
/// - Debouncing and mutex support
/// - Authentication state synchronization
///
/// Example:
/// ```dart
/// // Create a typed API instance
/// final api = TurboFirestoreApi<User>(
///   collectionPath: 'users',
///   fromJson: User.fromJson,
///   toJson: (user) => user.toJson(),
/// );
///
/// // Create a document
/// final response = await api.createDoc(
///   writeable: user,
///   timestampType: TurboTimestampType.createdAndUpdated,
/// );
///
/// // Stream real-time updates
/// api.streamAllWithConverter().listen((users) {
///   print('Got ${users.length} users');
/// });
/// ```
///
/// See the individual components for detailed documentation:
library;

export 'abstracts/t_firestore_collection.dart';

/// Abstracts
export 'abstracts/t_vars.dart';

/// Main API class and extensions
export 'apis/t_dummy_firestore_api.dart';
export 'apis/t_firestore_api.dart';

/// Constants
export 'constants/t_auth_errors.dart';
export 'constants/t_error_codes.dart';
export 'constants/t_firestore_api_defaults.dart';
export 'constants/t_values.dart';

/// Enums for configuring API behavior
export 'enums/t_operation_type.dart';
export 'enums/t_parse_type.dart';
export 'enums/t_search_term_type.dart';
export 'enums/t_timestamp_type.dart';

/// Exception types for error handling
export 'exceptions/invalid_json_exception.dart';
export 'exceptions/t_firestore_exception.dart';

/// Extensions for enhanced functionality
export 'extensions/completer_extension.dart';
export 'extensions/t_list_extension.dart';
export 'extensions/t_map_extension.dart';

/// Generators for dummy data
export 'generators/t_dummy_schema.dart';
export 'generators/t_value_generator.dart';
export 'generators/t_value_generator_registry.dart';
export 'generators/t_value_specs.dart';

/// Mixins for shared behavior
export 'mixins/t_exception_handler.dart';

/// Data models and utilities
export 'models/t_api_vars.dart';
export 'models/t_auth_vars.dart';
export 'models/t_sensitive_data.dart';
export 'models/t_write_batch_with_reference.dart';

/// Services for state management
export 'services/t_auth_sync_service.dart';
export 'services/t_collection_service.dart';
export 'services/t_document_service.dart';
export 'services/t_hook_collection_service.dart';
export 'services/t_post_collection_service.dart';
export 'services/t_post_document_service.dart';
export 'services/t_pre_collection_service.dart';
export 'services/t_pre_document_service.dart';

/// Type definitions
export 'typedefs/collection_reference_def.dart';
export 'typedefs/create_doc_def.dart';
export 'typedefs/t_locator_def.dart';
export 'typedefs/update_doc_def.dart';
export 'typedefs/upsert_doc_def.dart';

/// Core utilities for logging, debugging and
export 'util/t_firestore_logger.dart';
