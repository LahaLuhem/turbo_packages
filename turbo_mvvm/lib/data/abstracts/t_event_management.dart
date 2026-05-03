import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/typedefs/t_event_handler.dart';
import 'package:turbo_mvvm/utils/t_completer_queue.dart';

abstract class TEventManagement<EVENT extends Object> {
  TEventManagement() {
    _registerEvents();
    _initStream();
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  void _initStream() => _streamSubscription ??= _controller.stream.listen(
    (event) => _eventQueue.lockAndRun(
      run: (unlock) async {
        try {
          await _eventMap[event]?.call(event);
        } catch (error, stackTrace) {
          onEventError?.call(error, stackTrace, event);
        } finally {
          unlock();
        }
      },
    ),
    cancelOnError: cancelOnStreamError,
    onDone: onDone,
    onError: onStreamError,
  );

  void _registerEvents() {
    for (final event in events) {
      final handler = onEvent(event);
      _eventMap[event] = handler;
    }
  }

  @mustCallSuper
  FutureOr<void> dispose() async {
    await _controller.close();
    await _streamSubscription?.cancel();
    _eventMap.clear();
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  Set<EVENT> get events;
  TEventHandler<EVENT> onEvent(EVENT event);

  VoidCallback? get onDone => null;
  bool get cancelOnStreamError => false;
  void Function(Object error, StackTrace stackTrace)? get onStreamError => null;
  void Function(Object error, StackTrace stackTrace, EVENT event)? get onEventError => null;

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  StreamSubscription<EVENT>? _streamSubscription;
  final Map<EVENT, TEventHandler<EVENT>> _eventMap = {};
  final StreamController<EVENT> _controller = StreamController.broadcast();

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  final _eventQueue = TCompleterQueue();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  void send(EVENT event) => emit(event);
  void add(EVENT event) => emit(event);

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  Future<RESULT> emitAsync<RESULT>(EVENT event) async {
    final completer = _eventQueue.registerCompleter(event);
    _controller.add(event);
    return await completer.future;
  }

  void emit(EVENT event) => _controller.add(event);
}
