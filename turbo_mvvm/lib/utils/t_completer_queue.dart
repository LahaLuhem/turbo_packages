import 'dart:async';
import 'dart:collection';
import 'dart:ui';

class TCompleterQueue {
  final _completerQueue = Queue<Completer>();

  FutureOr<T> lockAndRun<T>({
    required FutureOr<T> Function(VoidCallback unlock) run,
  }) async {
    final myCompleter = Completer();
    _completerQueue.add(myCompleter);
    for (final queuedCompleter in _completerQueue) {
      if (queuedCompleter == myCompleter) break;
      await queuedCompleter.future;
    }
    final value = await run(() => myCompleter.complete());
    _completerQueue.remove(myCompleter);
    return value;
  }

  void dispose() => _completerQueue.clear();
}
