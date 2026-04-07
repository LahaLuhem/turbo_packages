import 'package:test/test.dart';
import 'package:turbo_promptable/boxes/dtos/folder_dto.dart';

void main() {
  final t0 = DateTime.utc(2025, 1, 1);

  FolderDto baseDto({int? lastSyncedFileCount}) => FolderDto(
    id: 'f1',
    userId: 'u1',
    name: 'n',
    emoji: '📁',
    path: '/p',
    isActive: true,
    createdAt: t0,
    updatedAt: t0,
    lastSyncedFileCount: lastSyncedFileCount,
  );

  group('FolderDto serialization', () {
    test(
      'Given lastSyncedFileCount=42 When toJson Then map contains lastSyncedFileCount: 42',
      () {
        final json = baseDto(lastSyncedFileCount: 42).toJson();
        expect(json['lastSyncedFileCount'], 42);
      },
    );

    test(
      'Given JSON with lastSyncedFileCount: null When fromJson Then field is null',
      () {
        final dto = FolderDto.fromJson({
          'id': 'f1',
          'userId': 'u1',
          'name': 'n',
          'emoji': '📁',
          'path': '/p',
          'isActive': true,
          'createdAt': t0.toIso8601String(),
          'updatedAt': t0.toIso8601String(),
          'lastSyncedFileCount': null,
        });
        expect(dto.lastSyncedFileCount, isNull);
      },
    );

    test(
      'Given JSON without lastSyncedFileCount When fromJson Then field is null',
      () {
        final dto = FolderDto.fromJson({
          'id': 'f1',
          'userId': 'u1',
          'name': 'n',
          'emoji': '📁',
          'path': '/p',
          'isActive': true,
          'createdAt': t0.toIso8601String(),
          'updatedAt': t0.toIso8601String(),
        });
        expect(dto.lastSyncedFileCount, isNull);
      },
    );
  });

  group('UpdateFolderDtoRequest serialization', () {
    test(
      'Given lastSyncedFileCount=42 When toJson Then map has lastSyncedFileCount and no other field keys',
      () {
        final json = UpdateFolderDtoRequest(lastSyncedFileCount: 42).toJson();
        expect(json['lastSyncedFileCount'], 42);
        expect(json.containsKey('name'), isFalse);
        expect(json.containsKey('emoji'), isFalse);
        expect(json.containsKey('path'), isFalse);
        expect(json.containsKey('isActive'), isFalse);
        expect(json.containsKey('updatedAt'), isTrue);
      },
    );

    test(
      'Given lastSyncedFileCount=null When toJson Then map omits lastSyncedFileCount',
      () {
        final json = UpdateFolderDtoRequest(lastSyncedFileCount: null).toJson();
        expect(json.containsKey('lastSyncedFileCount'), isFalse);
      },
    );
  });
}
