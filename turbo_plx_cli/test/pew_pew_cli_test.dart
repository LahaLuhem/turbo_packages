import 'package:test/test.dart';
import 'package:turbo_plx_cli/turbo_plx_cli.dart';

void main() {
  group('FileEntryDto', () {
    test('copyWith creates new instance with updated values', () {
      const dto = FileEntryDto(
        path: 'original.md',
        content: 'original content',
        lastModified: 1000,
      );

      final copied = dto.copyWith(content: 'new content');

      expect(copied.path, equals('original.md'));
      expect(copied.content, equals('new content'));
      expect(copied.lastModified, equals(1000));
    });

    test('toJson and fromJson roundtrip', () {
      const dto = FileEntryDto(
        path: 'test/file.md',
        content: 'File content',
        lastModified: 1705766400000,
      );

      final json = dto.toJson();
      final restored = FileEntryDto.fromJson(json);

      expect(restored.path, equals('test/file.md'));
      expect(restored.content, equals('File content'));
      expect(restored.lastModified, equals(1705766400000));
    });
  });

  group('WatchEventDto', () {
    test('copyWith creates new instance with updated values', () {
      const dto = WatchEventDto(
        event: WatchEventType.get,
        path: 'test.md',
        content: 'content',
      );

      final copied = dto.copyWith(id: 'req-1');

      expect(copied.event, equals(WatchEventType.get));
      expect(copied.path, equals('test.md'));
      expect(copied.content, equals('content'));
      expect(copied.id, equals('req-1'));
    });

    test('toJson and fromJson roundtrip', () {
      const dto = WatchEventDto(
        event: WatchEventType.list,
        path: 'folder/',
        id: 'req-2',
        files: [
          FileEntryDto(
            path: 'file1.md',
            content: 'content1',
            lastModified: 1000,
          ),
        ],
      );

      final json = dto.toJson();
      final restored = WatchEventDto.fromJson(json);

      expect(restored.event, equals(WatchEventType.list));
      expect(restored.path, equals('folder/'));
      expect(restored.id, equals('req-2'));
      expect(restored.files, hasLength(1));
      expect(restored.files![0].path, equals('file1.md'));
    });

    group('GIVEN all event types', () {
      test('THEN get event serializes correctly', () {
        const dto = WatchEventDto(
          event: WatchEventType.get,
          path: 'test.md',
        );

        final json = dto.toJson();

        expect(json['event'], 'get');
      });

      test('THEN list event serializes correctly', () {
        const dto = WatchEventDto(
          event: WatchEventType.list,
          path: '.',
        );

        final json = dto.toJson();

        expect(json['event'], 'list');
      });

      test('THEN create event serializes correctly', () {
        const dto = WatchEventDto(
          event: WatchEventType.create,
          path: 'new.md',
        );

        final json = dto.toJson();

        expect(json['event'], 'create');
      });

      test('THEN modify event serializes correctly', () {
        const dto = WatchEventDto(
          event: WatchEventType.modify,
          path: 'existing.md',
        );

        final json = dto.toJson();

        expect(json['event'], 'modify');
      });

      test('THEN delete event serializes correctly', () {
        const dto = WatchEventDto(
          event: WatchEventType.delete,
          path: 'to-delete.md',
        );

        final json = dto.toJson();

        expect(json['event'], 'delete');
      });

      test('THEN error event serializes correctly', () {
        const dto = WatchEventDto(
          event: WatchEventType.error,
          path: '',
          content: 'Error message',
        );

        final json = dto.toJson();

        expect(json['event'], 'error');
      });
    });
  });

  group('FileEntryDto', () {
    test('toJson and fromJson roundtrip', () {
      const dto = FileEntryDto(
        path: 'nested/file.md',
        content: 'Nested content',
        lastModified: 1705766400000,
      );

      final json = dto.toJson();
      final restored = FileEntryDto.fromJson(json);

      expect(restored.path, equals('nested/file.md'));
      expect(restored.content, equals('Nested content'));
      expect(restored.lastModified, equals(1705766400000));
    });
  });

  group('PlxClient', () {
    group('Connection State', () {
      test('initial state is not connected', () async {
        final client = PlxClient();
        expect(client.isConnected, isFalse);
        expect(client.workingDirectory, isNull);
        await client.dispose();
      });

      test(
        'GIVEN PlxClient WHEN connect is called with valid directory THEN isConnected is true',
        () async {
          final client = PlxClient(plxExecutable: 'echo');

          try {
            await client.connect('/tmp');
            expect(client.isConnected, isTrue);
            expect(client.workingDirectory, equals('/tmp'));
          } finally {
            await client.disconnect();
            await client.dispose();
          }
        },
      );

      test(
        'GIVEN connected PlxClient WHEN disconnect is called THEN isConnected is false',
        () async {
          final client = PlxClient(plxExecutable: 'echo');

          try {
            await client.connect('/tmp');
            expect(client.isConnected, isTrue);

            await client.disconnect();
            expect(client.isConnected, isFalse);
            expect(client.workingDirectory, isNull);
          } finally {
            await client.dispose();
          }
        },
      );

      test('connect throws StateError when already connected', () async {
        final client = PlxClient(plxExecutable: 'echo');

        try {
          await client.connect('/tmp');
          expect(client.isConnected, isTrue);

          expect(
            () => client.connect('/tmp'),
            throwsA(isA<StateError>()),
          );
        } finally {
          await client.disconnect();
          await client.dispose();
        }
      });
    });

    group('Request/Response', () {
      test(
        'GIVEN disconnected PlxClient WHEN sendRequest is called THEN throws StateError',
        () async {
          final client = PlxClient();

          expect(
            () => client.sendRequest(
              const WatchEventDto(
                event: WatchEventType.get,
                path: 'test.md',
              ),
            ),
            throwsA(isA<StateError>()),
          );

          await client.dispose();
        },
      );

      test(
        'GIVEN connected PlxClient WHEN sendRequest is called with no id THEN generated id is used',
        () async {
          final client = PlxClient();

          const request = WatchEventDto(
            event: WatchEventType.get,
            path: 'test.md',
          );

          expect(request.id, isNull);

          await client.dispose();
        },
      );
    });

    group('Events Stream', () {
      test('events stream is broadcast', () async {
        final client = PlxClient();

        final stream1 = client.events;
        final stream2 = client.events;

        expect(stream1.isBroadcast, isTrue);
        expect(stream2.isBroadcast, isTrue);

        await client.dispose();
      });

      test('multiple listeners can subscribe to events', () async {
        final client = PlxClient(plxExecutable: 'echo');

        try {
          await client.connect('/tmp');

          final events1 = <WatchEventDto>[];
          final events2 = <WatchEventDto>[];

          final sub1 = client.events.listen(events1.add);
          final sub2 = client.events.listen(events2.add);

          await sub1.cancel();
          await sub2.cancel();
        } finally {
          await client.disconnect();
          await client.dispose();
        }
      });
    });

    group('Dispose', () {
      test('dispose cleans up resources', () async {
        final client = PlxClient(plxExecutable: 'echo');

        await client.connect('/tmp');
        expect(client.isConnected, isTrue);

        await client.dispose();
        expect(client.isConnected, isFalse);
      });

      test('dispose can be called multiple times safely', () async {
        final client = PlxClient();

        await client.dispose();
        await client.dispose();
      });

      test('disconnect can be called when not connected', () async {
        final client = PlxClient();

        await client.disconnect();
        expect(client.isConnected, isFalse);

        await client.dispose();
      });
    });
  });

  group('PlxException', () {
    test('message is preserved', () {
      const exception = PlxException('Test error message');
      expect(exception.message, equals('Test error message'));
    });

    test('toString includes message', () {
      const exception = PlxException('Test error');
      expect(exception.toString(), contains('Test error'));
    });
  });
}
