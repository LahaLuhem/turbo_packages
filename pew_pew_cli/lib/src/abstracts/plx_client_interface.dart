import 'dart:async';

import 'package:pew_pew_cli/src/dtos/watch_event_dto.dart';

abstract interface class PlxClientInterface {
  bool get isConnected;
  String? get workingDirectory;
  Stream<WatchEventDto> get events;

  Future<void> connect(String workingDirectory);
  Future<void> disconnect();
  Future<WatchEventDto> sendRequest(WatchEventDto request);
  Future<void> dispose();
}
