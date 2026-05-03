import 'dart:async';

typedef TEventHandler<EVENT> = FutureOr<void> Function(EVENT event);
