import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:turbolytics/turbolytics.dart';

import '../extensions/date_time_extensions.dart';

part '../analytics/t_analytics_service.dart';
part '../log/t_log.dart';
part 't_analytics_event_bus.dart';

/// Used to provide all logging, analytics and crashlytics functionality to a class of your choosing.
///
/// If you want to make use of the analytic functionality use [Turbolytics.setUp] to provide your
/// implementations of the [TAnalyticsInterface] and [CrashReportsInterface]. After doing so you can
/// add the [Turbolytics] mixin to any class where you would like to add logging and/or analytics to.
/// In order to have access to the appropriate [TAnalytics] implementation for a specific
/// feature or part of your project you should add the implementation as generic arguments to a
/// [Turbolytics] like `Turbolytics<CounterAnalytics>`.
///
/// Defining the generic [TAnalytics] is optional however as the [Turbolytics] will also work without
/// it. When no generic is specified you can even use our basic analytic functionality through the
/// default [TAnalytics.core] getter that's accessible through [Turbolytics.analytics].
mixin Turbolytics<D extends TAnalytics> {
  // Used to register and provider the proper [Analytics]
  static final GetIt _getIt = GetIt.asNewInstance();

  // Used to create an instance of Turbolytics when using a mixin is not possible or breaks a const constructor.
  static Turbolytics<T> create<T extends TAnalytics>({
    required String location,
  }) => _Turbolytics<T>(
    location: location,
  );

  /// Used to handle events in the proper order that they are sent.
  static final TAnalyticsEventBus _eventBus = TAnalyticsEventBus();

  /// Provides the configured [TAnalytics] functionality through the [Turbolytics] mixin per type of [D].
  late final D analytics = _getIt.get<D>()
    ..service = TAnalyticsService(log: log);

  /// Provides the configured [TAnalytics] functionality through the [Turbolytics] mixin per type of [A].
  A analyticsAs<A extends TAnalytics>() =>
      _getIt.get<A>()..service = TAnalyticsService(log: log);

  /// Provides any registered [TAnalytics] object per generic argument of [E].
  ///
  /// [location] is used for logging purposes, can be left out if desired.
  static E getAnalytics<E extends TAnalytics>({String? location}) =>
      _getIt.get<E>()
        ..service = TAnalyticsService(log: TLog(location: location));

  /// Used to provide all logging capabilities.
  late final TLog log = TLog(
    location: location,
    maxLinesStackTrace: _maxLinesStackTrace,
  );

  /// Used to define the location of Turbolytics logging and implementation.
  String get location => runtimeType.toString();

  // --------------- SETUP --------------- SETUP --------------- SETUP --------------- \\

  static TAnalyticsInterface? _analyticsInterface;
  static CrashReportsInterface? _crashReportsInterface;

  static int? _maxLinesStackTrace;
  static bool _combineEvents = true;
  static bool _isActive = false;
  static bool get isActive => _isActive;
  static bool _addAnalyticsToCrashReports = true;
  static TCrashReportType _crashReportType = TCrashReportType.location;

  /// Used to configure the logging and analytic abilities of the [Turbolytics].
  ///
  /// Use the [analyticsInterface] and [crashReportsInterface] to specify your implementations
  /// of both functionalities. This is optional as the [Turbolytics] can also be used as a pure logger.
  /// Populate the [analytics] parameter with callbacks to your [TAnalytics] implementations.
  /// Example: `[() => CounterAnalytics(), () => CookieAnalytics()]`.
  static void setUp({
    bool logTime = false,
    TLogLevel logLevel = TLogLevel.info,
    TAnalyticsInterface? analyticsInterface,
    CrashReportsInterface? crashReportsInterface,
    void Function(TAnalyticsFactory analyticsFactory)? analytics,
    int? maxLinesStackTrace,
    bool combineEvents = true,
    bool addAnalyticsToCrashReports = true,
    TCrashReportType crashReportType = TCrashReportType.location,
  }) {
    TLog.logTime = logTime;
    TLog.level = logLevel;
    _analyticsInterface = analyticsInterface;
    _crashReportsInterface = crashReportsInterface;
    if (analytics != null) {
      registerAnalytics(analytics: analytics);
    }
    _maxLinesStackTrace = maxLinesStackTrace;
    _combineEvents = combineEvents;
    _addAnalyticsToCrashReports = addAnalyticsToCrashReports;
    _eventBus._listen();
    _isActive = true;
    _crashReportType = crashReportType;
  }

  /// Used to register analytics objects, default to .
  static void registerAnalytics({
    required void Function(TAnalyticsFactory analyticsFactory) analytics,
    bool registerDefaultAnalytics = true,
  }) {
    final analyticsFactory = TAnalyticsFactory(getIt: _getIt);
    if (registerDefaultAnalytics) {
      analyticsFactory.registerAnalytic(() => TAnalytics());
    }
    analytics(analyticsFactory);
  }

  /// Used to reset analytics objects.
  static Future<void> resetAnalytics() => _getIt.reset();

  /// Used to configure the logging and analytic abilities of the [Turbolytics].
  static Future<void> disposeMe() async {
    _analyticsInterface = null;
    _crashReportsInterface = null;
    _maxLinesStackTrace = null;
    await resetAnalytics();
    await _eventBus.dispose();
    _isActive = false;
  }
}

/// Used to provide [Turbolytics] as a an object while keeping mixin functionality.
class _Turbolytics<X extends TAnalytics> with Turbolytics<X> {
  _Turbolytics({
    required String location,
  }) : _location = location;

  final String _location;

  @override
  String get location => _location;
}
