import 'dart:async';

import 'package:turbo_plx_cli/src/dtos/agent_event_dto.dart';
import 'package:turbo_plx_cli/src/dtos/agent_run_request_dto.dart';
import 'package:turbo_plx_cli/src/dtos/conversation_dto.dart';
import 'package:turbo_plx_cli/src/dtos/session_summary_dto.dart';
import 'package:turbo_plx_cli/src/dtos/watch_event_dto.dart';

abstract interface class PlxClientInterface {
  bool get isConnected;
  String? get workingDirectory;
  Stream<WatchEventDto> get events;
  Stream<AgentEventDto> get agentEvents;

  Future<void> connect(String workingDirectory);
  Future<void> disconnect();
  Future<WatchEventDto> sendRequest(WatchEventDto request);
  Future<List<SessionSummaryDto>> sendAgentSessionsList({String? dataDir});
  Future<ConversationDto> sendAgentSessionGet({
    required String sessionId,
    String? projectPath,
    String? dataDir,
  });
  void sendAgentRun(AgentRunRequestDto request);
  Future<void> dispose();
}
