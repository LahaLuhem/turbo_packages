import 'package:test/test.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';

const _requestBody = 'REQ';
const _systemPromptArgv = ['--system-prompt-file', '/tmp/sys.md'];
const _renderedSystemPrompt = 'SYS';

const _expectedStitchedBody =
    '<system-prompt>\n'
    'SYS\n'
    '</system-prompt>\n'
    '\n'
    '<user-request>\n'
    'REQ\n'
    '</user-request>';

const _expectedStitchedBodyEmptyRendered =
    '<system-prompt>\n'
    '\n'
    '</system-prompt>\n'
    '\n'
    '<user-request>\n'
    'REQ\n'
    '</user-request>';

void main() {
  group('TCliTool.headlessInvocation', () {
    test('Given claude with a request body, system prompt argv, and rendered system prompt, When headlessInvocation is built, Then executable is claude and arguments include isolation, system prompt flag, and -p with the request body', () {
      const cliTool = TCliTool.claude;

      final result = cliTool.headlessInvocation(
        requestBody: _requestBody,
        systemPromptArgv: _systemPromptArgv,
        renderedSystemPrompt: _renderedSystemPrompt,
      );

      expect(result.executable, equals('claude'));
      expect(
        result.arguments,
        equals([
          '--strict-mcp-config',
          '--system-prompt-file',
          '/tmp/sys.md',
          '-p',
          'REQ',
        ]),
      );
    });

    test('Given codex with a request body, system prompt argv, and rendered system prompt, When headlessInvocation is built, Then executable is codex and arguments are exec + isolation + a single stitched payload (systemPromptArgv ignored)', () {
      const cliTool = TCliTool.codex;

      final result = cliTool.headlessInvocation(
        requestBody: _requestBody,
        systemPromptArgv: _systemPromptArgv,
        renderedSystemPrompt: _renderedSystemPrompt,
      );

      expect(result.executable, equals('codex'));
      expect(
        result.arguments,
        equals([
          'exec',
          '-c',
          'mcp_servers={}',
          _expectedStitchedBody,
        ]),
      );
    });

    test('Given cursor with a request body, system prompt argv, and rendered system prompt, When headlessInvocation is built, Then executable is cursor-agent and arguments are -p followed by a single stitched payload (systemPromptArgv ignored, empty isolation)', () {
      const cliTool = TCliTool.cursor;

      final result = cliTool.headlessInvocation(
        requestBody: _requestBody,
        systemPromptArgv: _systemPromptArgv,
        renderedSystemPrompt: _renderedSystemPrompt,
      );

      expect(result.executable, equals('cursor-agent'));
      expect(
        result.arguments,
        equals([
          '-p',
          _expectedStitchedBody,
        ]),
      );
    });

    test('Given codex with an empty rendered system prompt and a non-empty request body, When headlessInvocation is built, Then the stitched payload still emits boundary tags around a blank system-prompt section', () {
      const cliTool = TCliTool.codex;

      final result = cliTool.headlessInvocation(
        requestBody: _requestBody,
        systemPromptArgv: const <String>[],
        renderedSystemPrompt: '',
      );

      expect(result.executable, equals('codex'));
      expect(
        result.arguments,
        equals([
          'exec',
          '-c',
          'mcp_servers={}',
          _expectedStitchedBodyEmptyRendered,
        ]),
      );
    });
  });
}
