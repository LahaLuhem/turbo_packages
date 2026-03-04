import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pew_pew_cli/src/abstracts/plx_client_interface.dart';
import 'package:pew_pew_cli/src/constants/pew_pew_cli_defaults.dart';
import 'package:pew_pew_cli/src/dtos/watch_event_dto.dart';
import 'package:pew_pew_cli/src/enums/watch_event_type.dart';

class PlxClient implements PlxClientInterface {
  PlxClient({
    this.plxExecutable = PewPewCliDefaults.plxExecutable,
    this.requestTimeout = PewPewCliDefaults.requestTimeout,
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
      final event = WatchEventDto.fromJson(json);

      if (event.id != null && _responseCompleters.containsKey(event.id)) {
        _responseCompleters.remove(event.id)!.complete(event);
      } else {
        _eventController.add(event);
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

  @override
  Future<void> dispose() async {
    await disconnect();
    await _eventController.close();
  }
}
