import 'dart:async';

import 'package:pew_pew_cli/pew_pew_cli.dart';
import 'package:test/test.dart';
import 'package:turbo_response/turbo_response.dart';

class MockPlxClient implements PlxClientInterface {
  WatchEventDto? lastRequest;
  WatchEventDto? responseToReturn;
  Exception? exceptionToThrow;
  final StreamController<WatchEventDto> _eventController =
      StreamController<WatchEventDto>.broadcast();

  @override
  bool get isConnected => true;

  @override
  String? get workingDirectory => '/mock/path';

  @override
  Stream<WatchEventDto> get events => _eventController.stream;

  @override
  Future<void> connect(String workingDirectory) async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<WatchEventDto> sendRequest(WatchEventDto request) async {
    lastRequest = request;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return responseToReturn!;
  }

  @override
  Future<void> dispose() async {
    await _eventController.close();
  }

  void emitEvent(WatchEventDto event) {
    _eventController.add(event);
  }
}

void main() {
  group('PlxApi', () {
    late MockPlxClient mockClient;
    late PlxApi api;

    setUp(() {
      mockClient = MockPlxClient();
      api = PlxApi(plxClient: mockClient);
    });

    tearDown(() async {
      await mockClient.dispose();
    });

    group('get', () {
      group('GIVEN path to existing file', () {
        group('WHEN get is called', () {
          test(
            'THEN returns TurboResponse.success with FileEntryDto',
            () async {
              mockClient.responseToReturn = const WatchEventDto(
                event: WatchEventType.get,
                path: 'test.md',
                content: 'File content',
                lastModified: 1705766400000,
                id: 'req-1',
              );

              final response = await api.get('test.md');

              expect(mockClient.lastRequest?.event, WatchEventType.get);
              expect(mockClient.lastRequest?.path, 'test.md');

              switch (response) {
                case Success<FileEntryDto>(:final result):
                  expect(result.path, 'test.md');
                  expect(result.content, 'File content');
                  expect(result.lastModified, 1705766400000);
                case Fail<FileEntryDto>():
                  fail('Expected success but got fail');
              }
            },
          );
        });
      });

      group('GIVEN path to non-existent file', () {
        group('WHEN get is called', () {
          test('THEN returns TurboResponse.fail', () async {
            mockClient.responseToReturn = const WatchEventDto(
              event: WatchEventType.error,
              path: 'missing.md',
              content: 'File does not exist',
              id: 'req-2',
            );

            final response = await api.get('missing.md');

            switch (response) {
              case Success<FileEntryDto>():
                fail('Expected fail but got success');
              case Fail<FileEntryDto>(:final message):
                expect(message, contains('does not exist'));
            }
          });
        });
      });

      group('GIVEN PlxClient throws', () {
        group('WHEN get is called', () {
          test('THEN returns TurboResponse.fail with exception', () async {
            mockClient.exceptionToThrow = Exception('Connection lost');

            final response = await api.get('test.md');

            switch (response) {
              case Success<FileEntryDto>():
                fail('Expected fail but got success');
              case Fail<FileEntryDto>(:final error):
                expect(error.toString(), contains('Connection lost'));
            }
          });
        });
      });
    });

    group('list', () {
      group('GIVEN path to folder with files', () {
        group('WHEN list is called', () {
          test(
            'THEN returns TurboResponse.success with List<FileEntryDto>',
            () async {
              mockClient.responseToReturn = const WatchEventDto(
                event: WatchEventType.list,
                path: '.',
                id: 'req-3',
                files: [
                  FileEntryDto(
                    path: 'file1.md',
                    content: 'Content 1',
                    lastModified: 1705766400000,
                  ),
                  FileEntryDto(
                    path: 'file2.md',
                    content: 'Content 2',
                    lastModified: 1705766500000,
                  ),
                ],
              );

              final response = await api.list('.');

              expect(mockClient.lastRequest?.event, WatchEventType.list);
              expect(mockClient.lastRequest?.path, '.');

              switch (response) {
                case Success<List<FileEntryDto>>(:final result):
                  expect(result.length, 2);
                  expect(result[0].path, 'file1.md');
                  expect(result[0].content, 'Content 1');
                  expect(result[1].path, 'file2.md');
                  expect(result[1].content, 'Content 2');
                case Fail<List<FileEntryDto>>():
                  fail('Expected success but got fail');
              }
            },
          );
        });
      });

      group('GIVEN path to empty folder', () {
        group('WHEN list is called', () {
          test('THEN returns TurboResponse.success with empty list', () async {
            mockClient.responseToReturn = const WatchEventDto(
              event: WatchEventType.list,
              path: 'empty',
              id: 'req-4',
              files: [],
            );

            final response = await api.list('empty');

            switch (response) {
              case Success<List<FileEntryDto>>(:final result):
                expect(result, isEmpty);
              case Fail<List<FileEntryDto>>():
                fail('Expected success but got fail');
            }
          });
        });
      });

      group('GIVEN path to non-existent folder', () {
        group('WHEN list is called', () {
          test('THEN returns TurboResponse.fail', () async {
            mockClient.responseToReturn = const WatchEventDto(
              event: WatchEventType.error,
              path: 'missing-folder',
              content: 'Directory does not exist',
              id: 'req-5',
            );

            final response = await api.list('missing-folder');

            switch (response) {
              case Success<List<FileEntryDto>>():
                fail('Expected fail but got success');
              case Fail<List<FileEntryDto>>(:final message):
                expect(message, contains('does not exist'));
            }
          });
        });
      });

      group('GIVEN list response with null files', () {
        group('WHEN list is called', () {
          test('THEN returns empty list', () async {
            mockClient.responseToReturn = const WatchEventDto(
              event: WatchEventType.list,
              path: '.',
              id: 'req-6',
              files: null,
            );

            final response = await api.list('.');

            switch (response) {
              case Success<List<FileEntryDto>>(:final result):
                expect(result, isEmpty);
              case Fail<List<FileEntryDto>>():
                fail('Expected success but got fail');
            }
          });
        });
      });
    });

    group('create', () {
      group('GIVEN valid path and content', () {
        group('WHEN create is called', () {
          test(
            'THEN returns TurboResponse.success with FileEntryDto',
            () async {
              mockClient.responseToReturn = const WatchEventDto(
                event: WatchEventType.create,
                path: 'new-file.md',
                content: 'New content',
                lastModified: 1705766400000,
                id: 'req-7',
              );

              final response = await api.create('new-file.md', 'New content');

              expect(mockClient.lastRequest?.event, WatchEventType.create);
              expect(mockClient.lastRequest?.path, 'new-file.md');
              expect(mockClient.lastRequest?.content, 'New content');

              switch (response) {
                case Success<FileEntryDto>(:final result):
                  expect(result.path, 'new-file.md');
                  expect(result.content, 'New content');
                case Fail<FileEntryDto>():
                  fail('Expected success but got fail');
              }
            },
          );
        });
      });

      group('GIVEN create fails', () {
        group('WHEN create is called', () {
          test('THEN returns TurboResponse.fail', () async {
            mockClient.responseToReturn = const WatchEventDto(
              event: WatchEventType.error,
              path: 'invalid.json',
              content: 'File extension not allowed',
              id: 'req-8',
            );

            final response = await api.create('invalid.json', 'content');

            switch (response) {
              case Success<FileEntryDto>():
                fail('Expected fail but got success');
              case Fail<FileEntryDto>(:final message):
                expect(message, contains('extension'));
            }
          });
        });
      });
    });

    group('update', () {
      group('GIVEN valid path and content', () {
        group('WHEN update is called', () {
          test(
            'THEN returns TurboResponse.success with FileEntryDto',
            () async {
              mockClient.responseToReturn = const WatchEventDto(
                event: WatchEventType.modify,
                path: 'existing.md',
                content: 'Updated content',
                lastModified: 1705766500000,
                id: 'req-9',
              );

              final response = await api.update(
                'existing.md',
                'Updated content',
              );

              expect(mockClient.lastRequest?.event, WatchEventType.modify);
              expect(mockClient.lastRequest?.path, 'existing.md');
              expect(mockClient.lastRequest?.content, 'Updated content');

              switch (response) {
                case Success<FileEntryDto>(:final result):
                  expect(result.path, 'existing.md');
                  expect(result.content, 'Updated content');
                case Fail<FileEntryDto>():
                  fail('Expected success but got fail');
              }
            },
          );
        });
      });

      group('GIVEN update fails', () {
        group('WHEN update is called', () {
          test('THEN returns TurboResponse.fail', () async {
            mockClient.responseToReturn = const WatchEventDto(
              event: WatchEventType.error,
              path: 'missing.md',
              content: 'File does not exist',
              id: 'req-10',
            );

            final response = await api.update('missing.md', 'content');

            switch (response) {
              case Success<FileEntryDto>():
                fail('Expected fail but got success');
              case Fail<FileEntryDto>(:final message):
                expect(message, contains('does not exist'));
            }
          });
        });
      });
    });

    group('delete', () {
      group('GIVEN valid path', () {
        group('WHEN delete is called', () {
          test('THEN returns TurboResponse.success with true', () async {
            mockClient.responseToReturn = const WatchEventDto(
              event: WatchEventType.delete,
              path: 'to-delete.md',
              id: 'req-11',
            );

            final response = await api.delete('to-delete.md');

            expect(mockClient.lastRequest?.event, WatchEventType.delete);
            expect(mockClient.lastRequest?.path, 'to-delete.md');

            switch (response) {
              case Success<bool>(:final result):
                expect(result, isTrue);
              case Fail<bool>():
                fail('Expected success but got fail');
            }
          });
        });
      });

      group('GIVEN delete fails', () {
        group('WHEN delete is called', () {
          test('THEN returns TurboResponse.fail', () async {
            mockClient.responseToReturn = const WatchEventDto(
              event: WatchEventType.error,
              path: 'missing.md',
              content: 'File does not exist',
              id: 'req-12',
            );

            final response = await api.delete('missing.md');

            switch (response) {
              case Success<bool>():
                fail('Expected fail but got success');
              case Fail<bool>(:final message):
                expect(message, contains('does not exist'));
            }
          });
        });
      });
    });

    group('stream', () {
      group('GIVEN connected PlxClient', () {
        group('WHEN file changes', () {
          test('THEN stream emits FileEntryDto', () async {
            final events = <FileEntryDto>[];
            final subscription = api.stream().listen(events.add);

            mockClient.emitEvent(
              const WatchEventDto(
                event: WatchEventType.create,
                path: 'new-file.md',
                content: 'Created content',
                lastModified: 1705766400000,
              ),
            );

            mockClient.emitEvent(
              const WatchEventDto(
                event: WatchEventType.modify,
                path: 'modified-file.md',
                content: 'Modified content',
                lastModified: 1705766500000,
              ),
            );

            await Future<void>.delayed(const Duration(milliseconds: 50));
            await subscription.cancel();

            expect(events.length, 2);
            expect(events[0].path, 'new-file.md');
            expect(events[0].content, 'Created content');
            expect(events[1].path, 'modified-file.md');
            expect(events[1].content, 'Modified content');
          });
        });
      });

      group('GIVEN error events in stream', () {
        group('WHEN stream is listened to', () {
          test('THEN error events are filtered out', () async {
            final events = <FileEntryDto>[];
            final subscription = api.stream().listen(events.add);

            mockClient.emitEvent(
              const WatchEventDto(
                event: WatchEventType.create,
                path: 'file1.md',
                content: 'Content 1',
              ),
            );

            mockClient.emitEvent(
              const WatchEventDto(
                event: WatchEventType.error,
                path: '',
                content: 'Some error occurred',
              ),
            );

            mockClient.emitEvent(
              const WatchEventDto(
                event: WatchEventType.modify,
                path: 'file2.md',
                content: 'Content 2',
              ),
            );

            await Future<void>.delayed(const Duration(milliseconds: 50));
            await subscription.cancel();

            expect(events.length, 2);
            expect(events[0].path, 'file1.md');
            expect(events[1].path, 'file2.md');
          });
        });
      });
    });
  });
}
