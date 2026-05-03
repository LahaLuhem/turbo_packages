import 'dart:async';

typedef TEventHandler<EVENT> = FutureOr<dynamic> Function(EVENT event);
