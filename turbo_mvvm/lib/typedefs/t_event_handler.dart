import 'dart:async';

typedef TEventHandler<EVENT> = FutureOr<RESULT> Function<RESULT>(EVENT event);
