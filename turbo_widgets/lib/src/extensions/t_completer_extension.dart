import 'dart:async';

extension TCompleterExtension<T> on Completer<T> {
  void completeIfNotComplete([FutureOr<T>? value]) {
    if (!isCompleted) {
      complete(value);
    }
  }
}
