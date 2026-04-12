import 'dart:async';

import 'package:turbo_widgets/src/extensions/t_completer_extension.dart';

class TMinDurationCompleter {
  TMinDurationCompleter(this.duration);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final Duration duration;
  Completer<void>? _completer;
  Timer? _timer;

  // 🏗 HELPERS ------------------------------------------------------------------------------- \\

  void tryComplete() {
    _timer?.cancel();
    _completer?.completeIfNotComplete();
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void start() {
    tryComplete();
    _completer = Completer<void>();
    _timer = Timer(duration, () => tryComplete());
  }

  Future<void> get future {
    if (_completer == null) {
      start();
    }
    return _completer!.future;
  }
}
