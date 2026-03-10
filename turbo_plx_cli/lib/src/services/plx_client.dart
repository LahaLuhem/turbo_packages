import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:turbo_plx_cli/src/abstracts/plx_client_interface.dart';
import 'package:turbo_plx_cli/src/constants/turbo_plx_cli_defaults.dart';
import 'package:turbo_plx_cli/src/dtos/agent_event_dto.dart';
import 'package:turbo_plx_cli/src/dtos/agent_run_request_dto.dart';
import 'package:turbo_plx_cli/src/dtos/conversation_dto.dart';
import 'package:turbo_plx_cli/src/dtos/session_summary_dto.dart';
import 'package:turbo_plx_cli/src/dtos/watch_event_dto.dart';
import 'package:turbo_plx_cli/src/enums/watch_event_type.dart';

class PlxClient implements PlxClientInterface {
  PlxClient({
    this.plxExecutable = TurboPlxCliDefaults.plxExecutable,
    this.requestTimeout = TurboPlxCliDefaults.requestTimeout,
  });

  final String plxExecutable;
  final Duration requestTimeout;

  Process? _process;
  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;
  final StringBuffer _stderrBuffer = StringBuffer();

  bool _isConnected = false;
  @override
  bool get isConnected => _isConnected;

  String? _workingDirectory;
  @override
  String? get workingDirectory => _workingDirectory;

  final Map<String, Completer<WatchEventDto>> _responseCompleters = {};
  int _requestCounter = 0;

  final StreamController<WatchEventDto> _eventController =
      StreamController<WatchEventDto>.broadcast();
  @override
  Stream<WatchEventDto> get events => _eventController.stream;

  final StreamController<AgentEventDto> _agentEventController =
      StreamController<AgentEventDto>.broadcast();
  @override
  Stream<AgentEventDto> get agentEvents => _agentEventController.stream;

  Completer<List<SessionSummaryDto>>? _sessionsListCompleter;
  Completer<ConversationDto>? _sessionGetCompleter;

  String _generateRequestId() {
    _requestCounter++;
    return 'req-$_requestCounter';
  }

  @override
  Future<void> connect(String workingDirectory) async {
    if (_isConnected) {
      throw StateError('PlxClient is already connected');
    }

    _process = await Process.start(
      plxExecutable,
      ['watch', 'project'],
      workingDirectory: workingDirectory,
    );

    _workingDirectory = workingDirectory;

    _stdoutSubscription = _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_handleStdoutLine);

    _stderrSubscription = _process!.stderr
        .transform(utf8.decoder)
        .listen(_handleStderrData);

    unawaited(_process!.exitCode.then(_handleProcessExit));

    _isConnected = true;
  }

  void _handleStderrData(String data) {
    _stderrBuffer.write(data);
  }

  void _handleProcessExit(int exitCode) {
    if (!_isConnected) return;

    final stderrContent = _stderrBuffer.toString().trim();
    final errorMessage = stderrContent.isNotEmpty
        ? 'CLI process exited with code $exitCode: $stderrContent'
        : 'CLI process exited unexpectedly with code $exitCode';

    _eventController.add(
      WatchEventDto(
        event: WatchEventType.error,
        path: '',
        content: errorMessage,
      ),
    );

    for (final completer in _responseCompleters.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError(errorMessage));
      }
    }
    _responseCompleters.clear();

    _sessionsListCompleter?.completeError(StateError(errorMessage));
    _sessionsListCompleter = null;
    _sessionGetCompleter?.completeError(StateError(errorMessage));
    _sessionGetCompleter = null;

    _isConnected = false;
    _workingDirectory = null;
  }

  @override
  Future<void> disconnect() async {
    if (!_isConnected) return;

    _isConnected = false;
    _workingDirectory = null;

    await _stdoutSubscription?.cancel();
    _stdoutSubscription = null;

    await _stderrSubscription?.cancel();
    _stderrSubscription = null;

    _stderrBuffer.clear();

    _process?.kill();
    _process = null;

    for (final completer in _responseCompleters.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('PlxClient disconnected while request was pending'),
        );
      }
    }
    _responseCompleters.clear();

    _sessionsListCompleter?.completeError(
      StateError('PlxClient disconnected while request was pending'),
    );
    _sessionsListCompleter = null;
    _sessionGetCompleter?.completeError(
      StateError('PlxClient disconnected while request was pending'),
    );
    _sessionGetCompleter = null;
  }

  @override
  Future<WatchEventDto> sendRequest(WatchEventDto request) async {
    if (!_isConnected || _process == null) {
      throw StateError('PlxClient is not connected');
    }

    final id = request.id ?? _generateRequestId();
    final requestWithId = request.copyWith(id: id);

    final completer = Completer<WatchEventDto>();
    _responseCompleters[id] = completer;

    _process!.stdin.writeln(jsonEncode(requestWithId.toJson()));

    try {
      return await completer.future.timeout(
        requestTimeout,
        onTimeout: () {
          _responseCompleters.remove(id);
          throw TimeoutException('Request $id timed out', requestTimeout);
        },
      );
    } catch (e) {
      _responseCompleters.remove(id);
      rethrow;
    }
  }

  void _handleStdoutLine(String line) {
    if (line.trim().isEmpty) return;

    try {
      final json = jsonDecode(line) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case 'agent':
          _handleAgentEvent(json);
          return;
        case 'agent.sessions.list':
          _handleSessionsListResponse(json);
          return;
        case 'agent.session.get':
          _handleSessionGetResponse(json);
          return;
        default:
          _handleWatchEvent(json);
      }
    } catch (e) {
      _eventController.add(
        WatchEventDto(
          event: WatchEventType.error,
          path: '',
          content: 'Failed to parse CLI output: $e',
        ),
      );
    }
  }

  void _handleAgentEvent(Map<String, dynamic> json) {
    try {
      final event = AgentEventDto.fromJson(json);
      _agentEventController.add(event);
    } catch (_) {
      // Skip malformed agent events
    }
  }

  void _handleSessionsListResponse(Map<String, dynamic> json) {
    final completer = _sessionsListCompleter;
    _sessionsListCompleter = null;
    if (completer == null || completer.isCompleted) return;

    final error = json['error'] as String?;
    if (error != null) {
      completer.completeError(StateError(error));
      return;
    }

    final sessionsList = json['sessions'] as List<dynamic>? ?? [];
    final sessions = sessionsList
        .map(
          (e) => SessionSummaryDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    completer.complete(sessions);
  }

  void _handleSessionGetResponse(Map<String, dynamic> json) {
    final completer = _sessionGetCompleter;
    _sessionGetCompleter = null;
    if (completer == null || completer.isCompleted) return;

    final error = json['error'] as String?;
    if (error != null) {
      completer.completeError(StateError(error));
      return;
    }

    final conversation = ConversationDto.fromJson(json);
    completer.complete(conversation);
  }

  void _handleWatchEvent(Map<String, dynamic> json) {
    final event = WatchEventDto.fromJson(json);
    if (event.id != null && _responseCompleters.containsKey(event.id)) {
      _responseCompleters.remove(event.id)!.complete(event);
    } else {
      _eventController.add(event);
    }
  }

  @override
  Future<List<SessionSummaryDto>> sendAgentSessionsList({String? dataDir}) async {
    if (!_isConnected || _process == null) {
      throw StateError('PlxClient is not connected');
    }

    if (_sessionsListCompleter != null) {
      throw StateError(
        'Agent sessions list request already pending',
      );
    }

    final completer = Completer<List<SessionSummaryDto>>();
    _sessionsListCompleter = completer;

    final request = <String, dynamic>{
      'type': 'agent.sessions.list',
      if (dataDir != null) 'data_dir': dataDir,
    };
    _process!.stdin.writeln(jsonEncode(request));

    return completer.future.timeout(
      requestTimeout,
      onTimeout: () {
        _sessionsListCompleter = null;
        throw TimeoutException(
          'Agent sessions list timed out',
          requestTimeout,
        );
      },
    );
  }

  @override
  Future<ConversationDto> sendAgentSessionGet({
    required String sessionId,
    String? projectPath,
    String? dataDir,
  }) async {
    if (!_isConnected || _process == null) {
      throw StateError('PlxClient is not connected');
    }

    if (_sessionGetCompleter != null) {
      throw StateError(
        'Agent session get request already pending',
      );
    }

    final completer = Completer<ConversationDto>();
    _sessionGetCompleter = completer;

    final request = <String, dynamic>{
      'type': 'agent.session.get',
      'session_id': sessionId,
      if (projectPath != null) 'project_path': projectPath,
      if (dataDir != null) 'data_dir': dataDir,
    };
    _process!.stdin.writeln(jsonEncode(request));

    return completer.future.timeout(
      requestTimeout,
      onTimeout: () {
        _sessionGetCompleter = null;
        throw TimeoutException(
          'Agent session get timed out',
          requestTimeout,
        );
      },
    );
  }

  @override
  void sendAgentRun(AgentRunRequestDto request) {
    if (!_isConnected || _process == null) {
      throw StateError('PlxClient is not connected');
    }

    final json = request.toJson();
    json['type'] = 'agent.run';
    _process!.stdin.writeln(jsonEncode(json));
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _eventController.close();
    await _agentEventController.close();
  }
}
