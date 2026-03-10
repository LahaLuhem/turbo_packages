import 'dart:async';

import 'package:turbo_plx_cli/src/abstracts/plx_client_interface.dart';
import 'package:turbo_plx_cli/src/dtos/agent_event_dto.dart';
import 'package:turbo_plx_cli/src/dtos/agent_run_request_dto.dart';
import 'package:turbo_plx_cli/src/dtos/conversation_dto.dart';
import 'package:turbo_plx_cli/src/dtos/session_summary_dto.dart';

/// API for agent operations via plx CLI subprocess.
class PlxAgentApi {
  PlxAgentApi({required PlxClientInterface plxClient}) : _plxClient = plxClient;

  final PlxClientInterface _plxClient;

  /// Runs an agent and returns a stream of events for this run.
  /// Events are filtered by [runId]; if omitted, a client-generated id is used.
  Stream<AgentEventDto> runAgent({
    required String prompt,
    required List<String> args,
    required String cwd,
    String? runId,
    String? sessionId,
  }) {
    final effectiveRunId = runId ?? _generateRunId();
    final request = AgentRunRequestDto(
      prompt: prompt,
      args: args,
      cwd: cwd,
      runId: effectiveRunId,
      sessionId: sessionId,
    );
    _plxClient.sendAgentRun(request);
    return _plxClient.agentEvents.where((e) => e.runId == effectiveRunId);
  }

  /// Lists sessions from the Claude data directory.
  Future<List<SessionSummaryDto>> listSessions({String? dataDir}) =>
      _plxClient.sendAgentSessionsList(dataDir: dataDir);

  /// Fetches the transcript for a session.
  Future<ConversationDto> getSessionTranscript({
    required String sessionId,
    String? projectPath,
    String? dataDir,
  }) =>
      _plxClient.sendAgentSessionGet(
        sessionId: sessionId,
        projectPath: projectPath,
        dataDir: dataDir,
      );

  static int _runIdCounter = 0;

  String _generateRunId() =>
      'run-${DateTime.now().millisecondsSinceEpoch}-${_runIdCounter++}';
}
