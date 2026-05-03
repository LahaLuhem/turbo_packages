import 'dart:async';
import 'dart:collection';
import 'dart:ui';

class TCompleterQueue {
  final _completerQueue = Queue<Completer>();
  final Map<Object, Completer> _completersById = {};

  FutureOr<T> lockAndRun<T>({
    required FutureOr<T> Function(VoidCallback unlock) run,
    Object? completerId,
  }) async {
    final myCompleter = completerId == null ? Completer() : registerCompleter(completerId);
    _completerQueue.add(myCompleter);
    for (final queuedCompleter in _completerQueue) {
      if (queuedCompleter == myCompleter) break;
      await queuedCompleter.future;
    }
    final value = await run(() => myCompleter.complete());
    if (completerId != null) {
      _completersById.remove(completerId);
    }
    _completerQueue.remove(myCompleter);
    return value;
  }

  Completer registerCompleter(Object id) {
    Completer? completer = _completersById[id];
    if (completer == null) {
      completer = Completer();
      _completersById[id] = completer;
    }
    return completer;
  }

  void dispose({bool doTryCompleteAll = false}) {
    if (doTryCompleteAll) {
      for (final completer in _completerQueue) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }
    _completerQueue.clear();
    _completersById.clear();
  }
}
