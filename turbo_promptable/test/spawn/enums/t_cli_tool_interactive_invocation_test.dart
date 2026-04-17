import 'package:test/test.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';

const _systemPromptArgv = ['--system-prompt-file', '/tmp/sys.md'];

void main() {
  group('TCliTool.interactiveInvocation', () {
    test('Given claude with a system prompt argv, When interactiveInvocation is built, Then executable is claude and arguments are isolation followed by the system prompt argv', () {
      const cliTool = TCliTool.claude;

      final result = cliTool.interactiveInvocation(
        systemPromptArgv: _systemPromptArgv,
      );

      expect(result.executable, equals('claude'));
      expect(
        result.arguments,
        equals([
          '--strict-mcp-config',
          '--system-prompt-file',
          '/tmp/sys.md',
        ]),
      );
    });

    test('Given codex with a system prompt argv, When interactiveInvocation is built, Then executable is codex and arguments are only the isolation argv (systemPromptArgv ignored)', () {
      const cliTool = TCliTool.codex;

      final result = cliTool.interactiveInvocation(
        systemPromptArgv: _systemPromptArgv,
      );

      expect(result.executable, equals('codex'));
      expect(
        result.arguments,
        equals(const ['-c', 'mcp_servers={}']),
      );
    });

    test('Given cursor with a system prompt argv, When interactiveInvocation is built, Then executable is cursor-agent and arguments are an empty list (empty isolation, systemPromptArgv ignored)', () {
      const cliTool = TCliTool.cursor;

      final result = cliTool.interactiveInvocation(
        systemPromptArgv: _systemPromptArgv,
      );

      expect(result.executable, equals('cursor-agent'));
      expect(result.arguments, equals(const <String>[]));
    });
  });
}
