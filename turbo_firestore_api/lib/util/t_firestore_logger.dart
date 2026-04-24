import 'package:flutter/foundation.dart';
import 'package:turbo_firestore_api/models/t_sensitive_data.dart';
import 'package:turbolytics/turbolytics.dart';

/// A logger for the TurboFirestoreApi that handles different log levels and sensitive data.
///
/// This class provides logging functionality with different severity levels:
/// - Info: General information messages
/// - Success: Successful operation messages
/// - Warning: Warning messages that don't prevent operation
/// - Error: Error messages with optional stack traces
///
/// Example:
/// ```dart
/// final logger = TFirestoreLogger(
///   showSensitiveData: false,
/// );
/// ```
class TFirestoreLogger {
  /// Creates a logger with customizable settings.
  ///
  /// Set [showSensitiveData] to false to hide sensitive data in logs.
  /// The prefix parameters customize the prefix text for each log type.
  TFirestoreLogger({
    TLog? log,
    this.showSensitiveData = kDebugMode,
  }) : _log = log ?? TLog(location: 'TurboFirestoreApi');

  final TLog _log;

  /// Whether to include sensitive data in log messages
  final bool showSensitiveData;

  /// Logs an informational message.
  ///
  /// The [message] is the main log text. Optional [sensitiveData] will be logged
  /// if [showSensitiveData] is true.
  void debug({
    required String message,
    TSensitiveData? sensitiveData,
  }) {
    _log.debug(message);
    if (showSensitiveData && sensitiveData != null) {
      _log.debug(sensitiveData.toString());
    }
  }

  /// Logs a success message.
  ///
  /// The [message] is the main log text. Optional [sensitiveData] will be logged
  /// if [showSensitiveData] is true.
  void info({
    required String message,
    TSensitiveData? sensitiveData,
  }) {
    _log.info(message);
    if (showSensitiveData && sensitiveData != null) {
      _log.info(sensitiveData.toString());
    }
  }

  /// Logs a warning message.
  ///
  /// The [message] is the main log text. Optional [sensitiveData] will be logged
  /// if [showSensitiveData] is true.
  void warning({
    required String message,
    TSensitiveData? sensitiveData,
  }) {
    _log.warning(message);
    if (showSensitiveData && sensitiveData != null) {
      _log.warning(sensitiveData.toString());
    }
  }

  /// Logs an error message with optional stack trace information.
  ///
  /// The [message] is the main error description.
  /// [error] is the error object that was caught.
  /// [stackTrace] is the stack trace associated with the error.
  /// [sensitiveData] provides additional context that will be logged if [showSensitiveData] is true.
  void error({
    Object? error,
    StackTrace? stackTrace,
    required TSensitiveData? sensitiveData,
    required String message,
  }) {
    _log.error(
      message,
      error: error,
      stackTrace: stackTrace,
    );
    if (showSensitiveData && sensitiveData != null) {
      _log.error(sensitiveData.toString());
    }
  }
}
