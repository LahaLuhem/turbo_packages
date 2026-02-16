part of '../turbolytics/turbolytics.dart';

/// Used to provide an easy interface for sending analytics.
///
/// Each [TAnalyticsType] has its own method that receives a subject and possible parameters.
/// For example when using the [TAnalyticsService.viewed] method with given subject 'counter_page'
/// your [TAnalyticsService._analyticsInterface] will attempt to send a 'counter_page_viewed'
/// event.
class TAnalyticsService {
  TAnalyticsService({TLog? log}) : _log = log;

  /// Used to log analytics from where they are sent.
  final TLog? _log;

  /// Used to handle analytics in proper order that they are sent.
  late final TAnalyticsEventBus _eventBus = TAnalyticsEventBus();

  /// Used to identify the first input when sending a stream of similar analytics.
  TAnalytic? _firstInput;

  /// Sets a [userId] that persists throughout the app's lifecycle.
  ///
  /// This applies to your possible [_analyticsInterface] as well as your
  /// [_crashReportsInterface].
  void userId({required String userId}) {
    _eventBus.tryAddAnalytic(
      Turbolytics._analyticsInterface?.setUserId(userId),
    );
    _eventBus.tryAddCrashReport(
      Turbolytics._crashReportsInterface?.setUserIdentifier(userId),
    );
    _log?.analytic(
      name: 'user_id',
      value: userId,
      addToCrashReports: Turbolytics._addAnalyticsToCrashReports,
    );
  }

  /// Sets a user [property] and [value] that persists throughout the app.
  ///
  /// This applies to your possible [_analyticsInterface] as well as your
  /// [_crashReportsInterface].
  void userProperty({required String property, required String? value}) {
    _eventBus.tryAddAnalytic(
      Turbolytics._analyticsInterface?.setUserProperty(
        name: property,
        value: value,
      ),
    );
    _eventBus.tryAddCrashReport(
      Turbolytics._crashReportsInterface?.setCustomKey(
        property,
        value,
      ),
    );
    _log?.analytic(
      name: '[PROPERTY] $property',
      value: value,
      addToCrashReports: Turbolytics._addAnalyticsToCrashReports,
    );
  }

  /// Main method used for sending for the more flexible [CustomAnalytic]s.
  void custom({required CustomAnalytic analytic}) =>
      _logCustomAnalytic(analytic);

  /// Sends an [TAnalyticsType.tapped] based on given [subject] and possible [parameters].
  void tapped({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.tapped,
    ),
  );

  /// Sends an [TAnalyticsType.clicked] based on given [subject] and possible [parameters].
  void clicked({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.clicked,
    ),
  );

  /// Sends an [TAnalyticsType.focussed] based on given [subject] and possible [parameters].
  void focussed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.focussed,
    ),
  );

  /// Sends an [TAnalyticsType.selected] based on given [subject] and possible [parameters].
  void selected({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.selected,
    ),
  );

  /// Sends an [TAnalyticsType.connected] based on given [subject] and possible [parameters].
  void connected({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.connected,
    ),
  );

  /// Sends an [TAnalyticsType.disconnected] based on given [subject] and possible [parameters].
  void disconnected({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.disconnected,
    ),
  );

  /// Sends an [TAnalyticsType.viewed] based on given [subject] and possible [parameters].
  void viewed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.viewed,
    ),
  );

  /// Sends an [TAnalyticsType.hidden] based on given [subject] and possible [parameters].
  void hidden({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.hidden,
    ),
  );

  /// Sends an [TAnalyticsType.opened] based on given [subject] and possible [parameters].
  void opened({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.opened,
    ),
  );

  /// Sends an [TAnalyticsType.closed] based on given [subject] and possible [parameters].
  void closed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.closed,
    ),
  );

  /// Sends an [TAnalyticsType.failed] based on given [subject] and possible [parameters].
  void failed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.failed,
    ),
  );

  /// Sends an [TAnalyticsType.succeeded] based on given [subject] and possible [parameters].
  void succeeded({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.succeeded,
    ),
  );

  /// Sends an [TAnalyticsType.sent] based on given [subject] and possible [parameters].
  void sent({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.sent,
    ),
  );

  /// Sends an [TAnalyticsType.received] based on given [subject] and possible [parameters].
  void received({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.received,
    ),
  );

  /// Sends an [TAnalyticsType.validated] based on given [subject] and possible [parameters].
  void validated({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.validated,
    ),
  );

  /// Sends an [TAnalyticsType.invalidated] based on given [subject] and possible [parameters].
  void invalidated({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.invalidated,
    ),
  );

  /// Sends an [TAnalyticsType.searched] based on given [subject] and possible [parameters].
  void searched({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.searched,
    ),
  );

  /// Sends an [TAnalyticsType.liked] based on given [subject] and possible [parameters].
  void liked({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.liked,
    ),
  );

  /// Sends an [TAnalyticsType.shared] based on given [subject] and possible [parameters].
  void shared({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.shared,
    ),
  );

  /// Sends an [TAnalyticsType.commented] based on given [subject] and possible [parameters].
  void commented({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.commented,
    ),
  );

  /// Sends an [TAnalyticsType.input] based on given [subject] and possible [parameters].
  ///
  /// Defaults to only sending the first analytic by settings [onlyFirstValue] to true.
  void input({
    required String subject,
    Map<String, Object>? parameters,
    bool onlyFirstValue = true,
  }) {
    final analytic = TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.input,
    );
    if (_firstInput == null ||
        !onlyFirstValue ||
        !analytic.equals(_firstInput)) {
      _logAnalytic(analytic);
    }
    _firstInput = analytic;
  }

  /// Sends an [TAnalyticsType.incremented] based on given [subject] and possible [parameters].
  void incremented({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.incremented,
    ),
  );

  /// Sends an [TAnalyticsType.decremented] based on given [subject] and possible [parameters].
  void decremented({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.decremented,
    ),
  );

  /// Sends an [TAnalyticsType.accepted] based on given [subject] and possible [parameters].
  void accepted({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.accepted,
    ),
  );

  /// Sends an [TAnalyticsType.declined] based on given [subject] and possible [parameters].
  void declined({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.declined,
    ),
  );

  /// Sends an [TAnalyticsType.alert] based on given [subject] and possible [parameters].
  void alert({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.alert,
    ),
  );

  /// Sends an [TAnalyticsType.scrolled] based on given [subject] and possible [parameters].
  void scrolled({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.scrolled,
    ),
  );

  /// Sends an [TAnalyticsType.started] based on given [subject] and possible [parameters].
  void started({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.started,
    ),
  );

  /// Sends an [TAnalyticsType.stopped] based on given [subject] and possible [parameters].
  void stopped({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.stopped,
    ),
  );

  /// Sends an [TAnalyticsType.initialised] based on given [subject] and possible [parameters].
  void initialised({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.initialised,
    ),
  );

  /// Sends an [TAnalyticsType.disposed] based on given [subject] and possible [parameters].
  void disposed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.disposed,
    ),
  );

  /// Sends an [TAnalyticsType.fetched] based on given [subject] and possible [parameters].
  void fetched({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.fetched,
    ),
  );

  /// Sends an [TAnalyticsType.set] based on given [subject] and possible [parameters].
  void set({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.set,
    ),
  );

  /// Sends an [TAnalyticsType.get] based on given [subject] and possible [parameters].
  void get({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.get,
    ),
  );

  /// Sends an [TAnalyticsType.foreground] based on given [subject] and possible [parameters].
  void foreground({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.foreground,
    ),
  );

  /// Sends an [TAnalyticsType.background] based on given [subject] and possible [parameters].
  void background({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.background,
    ),
  );

  /// Sends an [TAnalyticsType.purchased] based on given [subject] and possible [parameters].
  void purchased({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.purchased,
    ),
  );

  /// Sends an [TAnalyticsType.dismissed] based on given [subject] and possible [parameters].
  void dismissed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.dismissed,
    ),
  );

  /// Sends an [TAnalyticsType.upgraded] based on given [subject] and possible [parameters].
  void upgraded({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.upgraded,
    ),
  );

  /// Sends an [TAnalyticsType.downgraded] based on given [subject] and possible [parameters].
  void downgraded({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.downgraded,
    ),
  );

  /// Sends an [TAnalyticsType.interaction] based on given [subject] and possible [parameters].
  void interaction({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.interaction,
    ),
  );

  /// Sends an [TAnalyticsType.query] based on given [subject] and possible [parameters].
  void query({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.query,
    ),
  );

  /// Sends an [TAnalyticsType.confirmed] based on given [subject] and possible [parameters].
  void confirmed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.confirmed,
    ),
  );

  /// Sends an [TAnalyticsType.canceled] based on given [subject] and possible [parameters].
  void canceled({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.canceled,
    ),
  );

  /// Sends an [TAnalyticsType.created] based on given [subject] and possible [parameters].
  void created({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.created,
    ),
  );

  /// Sends an [TAnalyticsType.read] based on given [subject] and possible [parameters].
  void read({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.read,
    ),
  );

  /// Sends an [TAnalyticsType.updated] based on given [subject] and possible [parameters].
  void updated({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.updated,
    ),
  );

  /// Sends an [TAnalyticsType.deleted] based on given [subject] and possible [parameters].
  void deleted({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.deleted,
    ),
  );

  /// Sends an [TAnalyticsType.added] based on given [subject] and possible [parameters].
  void added({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.added,
    ),
  );

  /// Sends an [TAnalyticsType.removed] based on given [subject] and possible [parameters].
  void removed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.removed,
    ),
  );

  /// Sends an [TAnalyticsType.subscribed] based on given [subject] and possible [parameters].
  void subscribed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.subscribed,
    ),
  );

  /// Sends an [TAnalyticsType.unsubscribed] based on given [subject] and possible [parameters].
  void unsubscribed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.unsubscribed,
    ),
  );

  /// Sends an [TAnalyticsType.changed] based on given [subject] and possible [parameters].
  void changed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.changed,
    ),
  );

  /// Sends an [TAnalyticsType.denied] based on given [subject] and possible [parameters].
  void denied({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.denied,
    ),
  );

  /// Sends an [TAnalyticsType.skipped] based on given [subject] and possible [parameters].
  void skipped({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.skipped,
    ),
  );

  /// Sends an [TAnalyticsType.checked] based on given [subject] and possible [parameters].
  void checked({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.checked,
    ),
  );

  /// Sends an [TAnalyticsType.unchecked] based on given [subject] and possible [parameters].
  void unchecked({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.unchecked,
    ),
  );

  /// Sends an [TAnalyticsType.attempted] based on given [subject] and possible [parameters].
  void attempted({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.attempted,
    ),
  );

  /// Sends an [TAnalyticsType.reset] based on given [subject] and possible [parameters].
  void reset({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.reset,
    ),
  );

  /// Sends an [TAnalyticsType.enabled] based on given [subject] and possible [parameters].
  void enabled({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.enabled,
    ),
  );

  /// Sends an [TAnalyticsType.disabled] based on given [subject] and possible [parameters].
  void disabled({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.disabled,
    ),
  );

  /// Sends an [TAnalyticsType.began] based on given [subject] and possible [parameters].
  void began({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.began,
    ),
  );

  /// Sends an [TAnalyticsType.ended] based on given [subject] and possible [parameters].
  void ended({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.ended,
    ),
  );

  /// Sends an [TAnalyticsType.refreshed] based on given [subject] and possible [parameters].
  void refreshed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.refreshed,
    ),
  );

  /// Sends an [TAnalyticsType.generated] based on given [subject] and possible [parameters].
  void generated({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.generated,
    ),
  );

  /// Sends an [TAnalyticsType.unsupported] based on given [subject] and possible [parameters].
  void unsupported({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.unsupported,
    ),
  );

  /// Sends an [TAnalyticsType.invalid] based on given [subject] and possible [parameters].
  void invalid({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.invalid,
    ),
  );

  /// Sends an [TAnalyticsType.valid] based on given [subject] and possible [parameters].
  void valid({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.valid,
    ),
  );

  /// Sends an [TAnalyticsType.shown] based on given [subject] and possible [parameters].
  void shown({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.shown,
    ),
  );

  /// Sends an [TAnalyticsType.saved] based on given [subject] and possible [parameters].
  void saved({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.saved,
    ),
  );

  /// Sends an [TAnalyticsType.loaded] based on given [subject] and possible [parameters].
  void loaded({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.loaded,
    ),
  );

  /// Sends an [TAnalyticsType.found] based on given [subject] and possible [parameters].
  void found({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.found,
    ),
  );

  /// Sends an [TAnalyticsType.notFound] based on given [subject] and possible [parameters].
  void notFound({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.notFound,
    ),
  );

  /// Sends an [TAnalyticsType.completed] based on given [subject] and possible [parameters].
  void completed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.completed,
    ),
  );

  /// Sends an [TAnalyticsType.error] based on given [subject] and possible [parameters].
  void error({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.error,
    ),
  );

  /// Sends an [TAnalyticsType.given] based on given [subject] and possible [parameters].
  void given({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.given,
    ),
  );

  /// Sends an [TAnalyticsType.taken] based on given [subject] and possible [parameters].
  void taken({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.taken,
    ),
  );

  /// Sends an [TAnalyticsType.snoozed] based on given [subject] and possible [parameters].
  void snoozed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.snoozed,
    ),
  );

  /// Sends an [TAnalyticsType.verified] based on given [subject] and possible [parameters].
  void verified({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.verified,
    ),
  );

  /// Sends an [TAnalyticsType.swiped] based on given [subject] and possible [parameters].
  void swiped({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.swiped,
    ),
  );

  /// Sends an [TAnalyticsType.used] based on given [subject] and possible [parameters].
  void used({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.used,
    ),
  );

  /// Sends an [TAnalyticsType.filled] based on given [subject] and possible [parameters].
  void filled({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.filled,
    ),
  );

  /// Sends an [TAnalyticsType.cleared] based on given [subject] and possible [parameters].
  void cleared({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.cleared,
    ),
  );

  /// Sends an [TAnalyticsType.unverified] based on given [subject] and possible [parameters].
  void unverified({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.unverified,
    ),
  );

  /// Sends an [TAnalyticsType.paused] based on given [subject] and possible [parameters].
  void paused({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.paused,
    ),
  );

  /// Sends an [TAnalyticsType.resumed] based on given [subject] and possible [parameters].
  void resumed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.resumed,
    ),
  );

  /// Sends an [TAnalyticsType.linked] based on given [subject] and possible [parameters].
  void linked({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.linked,
    ),
  );

  /// Sends an [TAnalyticsType.unlinked] based on given [subject] and possible [parameters].
  void unlinked({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.unlinked,
    ),
  );

  /// Sends an [TAnalyticsType.requested] based on given [subject] and possible [parameters].
  void requested({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.requested,
    ),
  );

  /// Sends an [TAnalyticsType.pressed] based on given [subject] and possible [parameters].
  void pressed({
    required String subject,
    Map<String, Object>? parameters,
  }) => _logAnalytic(
    TAnalytic(
      subject: subject,
      parameters: parameters,
      type: TAnalyticsType.pressed,
    ),
  );

  /// Sends the current screen based on given [subject] and possible [parameters].
  void screen({
    required String subject,
  }) {
    final name = subject;
    _eventBus.tryAddAnalytic(
      Turbolytics._analyticsInterface?.setCurrentScreen(name: name),
    );
    _log?.analytic(
      name: '[SCREEN] $name',
      addToCrashReports: Turbolytics._addAnalyticsToCrashReports,
    );
  }

  /// Resets all current analytics data.
  Future<void> resetAnalytics() async =>
      Turbolytics._analyticsInterface?.resetAnalyticsData();

  /// Resets the [_firstInput] used by [TAnalyticsService.input].
  void resetFirstInput() => _firstInput = null;

  /// Main method used for sending any [analytic] in this class.
  void _logAnalytic(TAnalytic analytic) {
    final name = analytic.name;
    final parameters = analytic.parameters;
    _eventBus.tryAddAnalytic(
      Turbolytics._analyticsInterface?.logEvent(
        name: name,
        parameters: parameters,
      ),
    );
    _log?.analytic(
      name: name,
      parameters: parameters,
      addToCrashReports: Turbolytics._addAnalyticsToCrashReports,
    );
  }

  /// Alternate method used for sending [CustomAnalytic]s.
  void _logCustomAnalytic(CustomAnalytic customAnalytic) {
    final name = customAnalytic.name;
    final parameters = customAnalytic.parameters;
    _eventBus.tryAddAnalytic(
      Turbolytics._analyticsInterface?.logEvent(
        name: name,
        parameters: parameters,
      ),
    );
    _log?.analytic(
      name: name,
      parameters: parameters,
      addToCrashReports: Turbolytics._addAnalyticsToCrashReports,
    );
  }
}
