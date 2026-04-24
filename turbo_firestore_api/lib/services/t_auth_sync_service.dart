import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:turbo_firestore_api/enums/t_operation_type.dart';
import 'package:turbo_firestore_api/exceptions/t_firestore_exception.dart';
import 'package:turbo_firestore_api/mixins/t_exception_handler.dart';
import 'package:turbolytics/turbolytics.dart';

/// A service that synchronizes data with Firebase Authentication state changes.
///
/// Provides automatic data synchronization based on user authentication state:
/// - Starts streaming data when a user signs in
/// - Clears data when user signs out
/// - Handles stream errors with automatic retries
/// - Manages stream lifecycle
///
/// Type Parameters:
/// - [StreamValue] - The type of data being streamed
abstract class TAuthSyncService<StreamValue> with TExceptionHandler {
  /// Creates a new [TAuthSyncService] instance.
  ///
  /// Parameters:
  /// - [initialiseStream] - Whether to start the stream immediately
  TAuthSyncService({
    bool initialiseStream = true,
  }) {
    if (initialiseStream) {
      tryInitialiseStream();
    }
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  /// Called when a stream error occurs.
  ///
  /// Override this method to handle specific error types.
  /// Parameters:
  /// - [error] - The Firestore exception that occurred
  void onError(TFirestoreException error) {
    // Default implementation logs the error
    _log.warning('Stream error occurred (onError not overridden): $error');
  }

  /// Initializes the authentication state stream and data synchronization.
  ///
  /// Sets up listeners for user authentication changes and manages the data stream.
  Future<void> tryInitialiseStream() async {
    _log.info('Initialising TurboAuthSyncService stream..');
    try {
      _userSubscription ??= FirebaseAuth.instance.userChanges().listen(
        (user) async {
          final userId = user?.uid;
          if (userId != null) {
            cachedUserId = userId;
            await onAuth?.call(user!);

            // Ensure auth token is ready and cached before starting Firestore stream
            // This ensures Firestore security rules have access to request.auth
            try {
              await _ensureAuthTokenReady(user!);
            } catch (error, stackTrace) {
              _log.error(
                'Failed to ensure auth token ready, proceeding anyway',
                error: error,
                stackTrace: stackTrace,
              );
              // Continue - let the stream attempt and retry mechanism handle failures
            }

            // Cancel any existing subscription before creating a new one
            // This ensures we start fresh with the token-ready user
            await _subscription?.cancel();
            _subscription = null;

            _subscription = (await stream(user!)).listen(
              (value) async {
                await onData(value, user);
              },
              onError: (Object error, StackTrace stackTrace) {
                _log.error(
                  'Stream error occurred inside of stream!',
                  error: error,
                  stackTrace: stackTrace,
                );

                // Convert error to TurboFirestoreException if needed
                final exception = error is TFirestoreException
                    ? error
                    : TFirestoreException.fromFirestoreException(
                        error,
                        stackTrace,
                        operationType: TOperationType.stream,
                      );

                // Call onError handler
                onError(exception);

                _tryRetry();
              },
              onDone: () => onDone(_nrOfRetry, _maxNrOfRetry),
            );
          } else {
            cachedUserId = null;
            _clearTokenCache();
            await _subscription?.cancel();
            _subscription = null;
            await onData(null, null);
          }
        },
      );
    } catch (error, stack) {
      _log.error(
        'Stream error occurred while setting up stream!',
        error: error,
        stackTrace: stack,
      );

      // Convert error to TurboFirestoreException if needed
      final exception = error is TFirestoreException
          ? error
          : TFirestoreException.fromFirestoreException(
              error,
              stack,
              operationType: TOperationType.stream,
            );

      // Call onError handler
      onError(exception);

      _tryRetry();
    }
  }

  /// Cleans up resources and resets the service state.
  @mustCallSuper
  Future<void> dispose() async {
    _log.warning('Disposing TurboAuthSyncService!');
    await _clearStream();
    _resetRetryTimer();
    _clearTokenCache();
    _nrOfRetry = 0;
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// The ID of the currently authenticated user.
  String? cachedUserId;

  /// Cached token result with claims for the current user.
  IdTokenResult? _cachedTokenResult;

  /// User ID for which the token was cached (to invalidate on user change).
  String? _cachedTokenUserId;

  /// Subscription to the data stream.
  StreamSubscription<StreamValue?>? _subscription;

  /// Subscription to the authentication state stream.
  StreamSubscription<User?>? _userSubscription;

  /// Timer for retry attempts.
  Timer? _retryTimer;

  /// Maximum number of retry attempts.
  final _maxNrOfRetry = 20;

  /// Current number of retry attempts.
  int _nrOfRetry = 0;

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Logger instance for this service.
  late final _log = TLog(location: runtimeType.toString());

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Returns the cached token result with claims.
  ///
  /// Returns `null` if no token has been cached yet.
  Future<IdTokenResult?> getTokenResult() async {
    return _cachedTokenResult;
  }

  /// Returns all custom claims from the cached token.
  ///
  /// Returns `null` if no token has been cached yet or if there are no claims.
  Map<String, dynamic>? getCustomClaims() {
    return _cachedTokenResult?.claims;
  }

  /// Returns a specific custom claim by key.
  ///
  /// Parameters:
  /// - [key] - The claim key to retrieve
  /// - [defaultValue] - The default value to return if the claim doesn't exist
  ///
  /// Returns the claim value if found, otherwise returns [defaultValue].
  T? getCustomClaim<T>(String key, {T? defaultValue}) {
    final claims = getCustomClaims();
    if (claims == null) return defaultValue;
    final value = claims[key];
    if (value is T) return value;
    return defaultValue;
  }

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  /// Ensures the auth token is ready and cached for the given user.
  ///
  /// This method fetches and caches the token only once per user. If the token
  /// is already cached for this user, it returns immediately without making
  /// another network request.
  ///
  /// After refreshing the token, this method performs a simple Firestore read
  /// operation to force Firestore to synchronize its internal auth state with
  /// the refreshed token. This is necessary because Firestore has its own
  /// internal auth state that may not automatically sync after getIdToken().
  ///
  /// Parameters:
  /// - [user] - The Firebase user for which to ensure the token is ready
  ///
  /// Throws an exception if token retrieval fails.
  Future<void> _ensureAuthTokenReady(User user) async {
    // If token is already cached for this user, return early
    if (_cachedTokenUserId == user.uid && _cachedTokenResult != null) {
      _log.debug('Auth token already cached for user ${user.uid}');
      return;
    }

    try {
      _log.debug('Fetching auth token for user ${user.uid}');
      // Refresh the token to ensure it's up to date
      await user.getIdToken(true);
      // Get the token result with claims
      _cachedTokenResult = await user.getIdTokenResult();
      // Store the user ID for which we cached the token
      _cachedTokenUserId = user.uid;
      _log.debug('Auth token cached successfully for user ${user.uid}');
      _logTokenDiagnostics(user, _cachedTokenResult);
    } catch (error, stackTrace) {
      _log.error(
        'Failed to get auth token for user ${user.uid}',
        error: error,
        stackTrace: stackTrace,
      );
      // Clear cache on error to force retry on next attempt
      _clearTokenCache();
      rethrow;
    }
  }

  /// Clears the cached token and token result.
  ///
  /// This should be called when the user signs out to ensure a fresh token
  /// is fetched when a new user signs in.
  void _clearTokenCache() {
    _cachedTokenResult = null;
    _cachedTokenUserId = null;
    _log.debug('Token cache cleared');
  }

  void _logTokenDiagnostics(User user, IdTokenResult? tokenResult) {
    try {
      final payload = _decodeJwtPayload(tokenResult?.token);
      _log.debug(
        'Auth token diagnostics -> uid: ${user.uid}, '
        'aud: ${payload?['aud']}, iss: ${payload?['iss']}, sub: ${payload?['sub']}',
      );
      _log.debug(
        'Firebase projectIds -> auth: ${FirebaseAuth.instance.app.options.projectId}, '
        'firestore: ${FirebaseFirestore.instance.app.options.projectId}',
      );
    } catch (error, stackTrace) {
      _log.warning(
        'Failed to decode auth token for diagnostics. Error: $error\n$stackTrace',
      );
    }
  }

  Map<String, dynamic>? _decodeJwtPayload(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final decoded = jsonDecode(payload);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Returns a stream of data for the authenticated user.
  FutureOr<Stream<StreamValue?>> Function(User user) get stream;

  /// Handles data updates from the stream.
  Future<void> Function(StreamValue? value, User? user) get onData;

  /// Called when a user is authenticated.
  FutureOr<void> Function(User user)? onAuth;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Resets and reinitialized the stream.
  Future<void> resetAndTryInitialiseStream() async {
    await _clearStream();
    await tryInitialiseStream();
  }

  /// Called when the stream is done.
  void onDone(int nrOfRetry, int maxNrOfRetry) {
    _log.warning('TurboAuthSyncService stream is done!');
  }

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  /// Resets the stream subscriptions.
  Future<void> _clearStream() async {
    await _userSubscription?.cancel();
    _userSubscription = null;
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Resets the retry timer.
  void _resetRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Attempts to retry stream initialization after an error.
  void _tryRetry() {
    if (_nrOfRetry < _maxNrOfRetry) {
      if (_retryTimer?.isActive ?? false) {
        _resetRetryTimer();
        _log.info('Retry reset!');
      }
      _log.info(
        'Initiating stream retry $_nrOfRetry/$_maxNrOfRetry for TurboAuthSyncService in 10 seconds..',
      );
      _retryTimer = Timer(
        const Duration(seconds: 10),
        () {
          _nrOfRetry++;
          _clearStream();
          tryInitialiseStream();
          _retryTimer = null;
        },
      );
    } else {
      _clearStream();
    }
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
}
