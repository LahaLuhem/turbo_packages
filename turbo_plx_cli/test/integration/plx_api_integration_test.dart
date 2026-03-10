@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turbo_plx_cli/turbo_plx_cli.dart';
import 'package:turbo_response/turbo_response.dart';

void main() {
  late Directory tempDir;
  late PlxClient plxClient;
  late PlxApi plxApi;
  late String plxExecutable;
  late String silentMockExecutable;

  setUpAll(() async {
    final pewPewPlxPath =
        Platform.environment['PEW_PEW_PLX_PATH'] ??
        '/Users/codaveto/Repos/pew_pew_plx';

    final buildResult = await Process.run(
      'dart',
      ['compile', 'exe', 'bin/plx.dart', '-o', 'plx_test'],
      workingDirectory: pewPewPlxPath,
    );

    if (buildResult.exitCode != 0) {
      throw Exception(
        'Failed to build plx CLI: ${buildResult.stderr}',
      );
    }

    plxExecutable = '$pewPewPlxPath/plx_test';

    // Build silent mock CLI for timeout tests
    final testDir = Directory.current.path;
    final mockCliPath =
        '$testDir/test/integration/helpers/silent_mock_cli.dart';
    final mockBuildResult = await Process.run(
      'dart',
      ['compile', 'exe', mockCliPath, '-o', '$testDir/silent_mock_cli_test'],
    );

    if (mockBuildResult.exitCode != 0) {
      throw Exception(
        'Failed to build silent mock CLI: ${mockBuildResult.stderr}',
      );
    }

    silentMockExecutable = '$testDir/silent_mock_cli_test';
  });

  tearDownAll(() async {
    final pewPewPlxPath =
        Platform.environment['PEW_PEW_PLX_PATH'] ??
        '/Users/codaveto/Repos/pew_pew_plx';
    final executable = File('$pewPewPlxPath/plx_test');
    if (executable.existsSync()) {
      executable.deleteSync();
    }

    final testDir = Directory.current.path;
    final mockExecutable = File('$testDir/silent_mock_cli_test');
    if (mockExecutable.existsSync()) {
      mockExecutable.deleteSync();
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('plx_integration_test_');

    final configFile = File('${tempDir.path}/plx.yaml');
    await configFile.writeAsString('''
watch:
  extensions:
    - .md
  ignore_folders:
    - .git
    - node_modules
  throttle_ms: 100
''');

    plxClient = PlxClient(
      plxExecutable: plxExecutable,
      requestTimeout: const Duration(seconds: 10),
    );

    plxApi = PlxApi(plxClient: plxClient);

    await plxClient.connect(tempDir.path);
  });

  tearDown(() async {
    await plxClient.disconnect();
    await plxClient.dispose();

    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PlxApi.get', () {
    test(
      'GIVEN existing file WHEN get is called THEN returns success with content',
      () async {
        final testFile = File('${tempDir.path}/test.md');
        await testFile.writeAsString('# Test Content');

        final response = await plxApi.get('test.md');

        switch (response) {
          case Success<FileEntryDto>(:final result):
            expect(result.path, equals('test.md'));
            expect(result.content, equals('# Test Content'));
            expect(result.lastModified, isNotNull);
          case Fail<FileEntryDto>():
            fail('Expected success but got fail');
        }
      },
    );

    test(
      'GIVEN non-existent file WHEN get is called THEN returns fail',
      () async {
        final response = await plxApi.get('non_existent.md');

        switch (response) {
          case Success<FileEntryDto>():
            fail('Expected fail but got success');
          case Fail<FileEntryDto>():
            expect(true, isTrue);
        }
      },
    );
  });

  group('PlxApi.list', () {
    test(
      'GIVEN folder with files WHEN list is called THEN returns all files',
      () async {
        await File('${tempDir.path}/file1.md').writeAsString('content1');
        await File('${tempDir.path}/file2.md').writeAsString('content2');
        await Directory('${tempDir.path}/subdir').create();
        await File('${tempDir.path}/subdir/file3.md').writeAsString('content3');

        final response = await plxApi.list('.');

        switch (response) {
          case Success<List<FileEntryDto>>(:final result):
            expect(result.length, equals(3));
            final paths = result.map((f) => f.path).toList();
            expect(
              paths,
              containsAll(['file1.md', 'file2.md', 'subdir/file3.md']),
            );
          case Fail<List<FileEntryDto>>():
            fail('Expected success but got fail');
        }
      },
    );

    test(
      'GIVEN empty folder WHEN list is called THEN returns empty list',
      () async {
        final emptyDir = Directory('${tempDir.path}/empty');
        await emptyDir.create();

        final response = await plxApi.list('empty');

        switch (response) {
          case Success<List<FileEntryDto>>(:final result):
            expect(result, isEmpty);
          case Fail<List<FileEntryDto>>():
            fail('Expected success but got fail');
        }
      },
    );
  });

  group('PlxApi.create', () {
    test(
      'GIVEN valid path and content WHEN create is called THEN file is created',
      () async {
        final response = await plxApi.create('new_file.md', '# New Content');

        switch (response) {
          case Success<FileEntryDto>(:final result):
            expect(result.path, equals('new_file.md'));
            final file = File('${tempDir.path}/new_file.md');
            expect(file.existsSync(), isTrue);
            expect(file.readAsStringSync(), equals('# New Content'));
          case Fail<FileEntryDto>():
            fail('Expected success but got fail');
        }
      },
    );
  });

  group('PlxApi.update', () {
    test(
      'GIVEN existing file WHEN update is called THEN file content is updated',
      () async {
        await File('${tempDir.path}/existing.md').writeAsString('old content');

        final response = await plxApi.update('existing.md', 'new content');

        switch (response) {
          case Success<FileEntryDto>():
            final file = File('${tempDir.path}/existing.md');
            expect(file.readAsStringSync(), equals('new content'));
          case Fail<FileEntryDto>():
            fail('Expected success but got fail');
        }
      },
    );
  });

  group('PlxApi.delete', () {
    test(
      'GIVEN existing file WHEN delete is called THEN file is removed',
      () async {
        final file = File('${tempDir.path}/to_delete.md');
        await file.writeAsString('to be deleted');
        expect(file.existsSync(), isTrue);

        final response = await plxApi.delete('to_delete.md');

        switch (response) {
          case Success<bool>():
            expect(file.existsSync(), isFalse);
          case Fail<bool>():
            fail('Expected success but got fail');
        }
      },
    );
  });

  group('PlxApi.stream', () {
    test(
      'GIVEN stream subscription WHEN file is modified THEN stream emits event',
      () async {
        final file = File('${tempDir.path}/stream_test.md');
        await file.writeAsString('initial content');

        final events = <FileEntryDto>[];
        final subscription = plxApi.stream().listen(events.add);

        await Future<void>.delayed(const Duration(milliseconds: 500));

        await file.writeAsString('modified content');

        await Future<void>.delayed(const Duration(seconds: 1));

        await subscription.cancel();

        expect(events, isNotEmpty);
        expect(
          events.any((e) => e.path.contains('stream_test.md')),
          isTrue,
        );
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });

  group('PlxClient.timeout', () {
    test(
      'GIVEN request to unresponsive CLI WHEN timeout expires THEN throws TimeoutException',
      () async {
        final timeoutClient = PlxClient(
          plxExecutable: silentMockExecutable,
          requestTimeout: const Duration(milliseconds: 200),
        );

        try {
          await timeoutClient.connect('/tmp');

          await expectLater(
            timeoutClient.sendRequest(
              const WatchEventDto(
                event: WatchEventType.get,
                path: 'test.md',
              ),
            ),
            throwsA(isA<TimeoutException>()),
          );
        } finally {
          await timeoutClient.disconnect();
          await timeoutClient.dispose();
        }
      },
    );
  });
}
