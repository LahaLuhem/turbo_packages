import 'package:test/test.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';

void main() {
  group('TCliTool.isolationArgv', () {
    test('Given claude, When isolationArgv is read, Then returns the strict-mcp-config flag', () {
      const cliTool = TCliTool.claude;

      final result = cliTool.isolationArgv;

      expect(result, equals(const ['--strict-mcp-config']));
    });

    test('Given codex, When isolationArgv is read, Then returns the mcp_servers config override', () {
      const cliTool = TCliTool.codex;

      final result = cliTool.isolationArgv;

      expect(result, equals(const ['-c', 'mcp_servers={}']));
    });

    test('Given cursor, When isolationArgv is read, Then returns an empty list (no documented flag exists)', () {
      const cliTool = TCliTool.cursor;

      final result = cliTool.isolationArgv;

      expect(result, equals(const <String>[]));
    });
  });

  group('TCliTool.command cursor rename', () {
    test('Given cursor, When command is read, Then returns cursor-agent', () {
      const cliTool = TCliTool.cursor;

      final result = cliTool.command;

      expect(result, equals('cursor-agent'));
    });
  });
}
