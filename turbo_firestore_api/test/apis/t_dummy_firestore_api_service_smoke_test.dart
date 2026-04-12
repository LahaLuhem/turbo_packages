import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/apis/t_dummy_firestore_api.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_firestore_api/typedefs/create_doc_def.dart';
import 'package:turbo_firestore_api/typedefs/update_doc_def.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

// ---------------------------------------------------------------------------
// Synthetic DTO
// ---------------------------------------------------------------------------

class _SmokeDto extends TWriteableId {
  _SmokeDto({
    required this.id,
    required this.name,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory _SmokeDto.fromJson(Map<String, dynamic> json) => _SmokeDto(
    id: json['id'] as String,
    name: json['name'] as String,
    isActive: json['isActive'] as bool,
    createdAt: json['createdAt'] as Timestamp?,
    updatedAt: json['updatedAt'] as Timestamp?,
  );

  @override
  final String id;
  final String name;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isActive': isActive,
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };

  _SmokeDto copyWith({String? name, bool? isActive}) => _SmokeDto(
    id: id,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

// ---------------------------------------------------------------------------
// Minimal TCollectionService subclass
// ---------------------------------------------------------------------------

class _SmokeCollectionService
    extends TCollectionService<_SmokeDto, TDummyFirestoreApi<_SmokeDto>> {
  _SmokeCollectionService({required super.api})
    : super(initialiseStream: false);

  @override
  FutureOr<Stream<List<_SmokeDto>?>> Function(User user) get stream =>
      (user) async => api.streamAllWithConverter();

  /// Preload local state from the first dummy emission.
  void hydrateLocalState(List<_SmokeDto> docs) {
    docsPerIdNotifier.update({for (final doc in docs) doc.id: doc});
  }

  /// Public wrapper over the protected [createDoc].
  Future<TurboResponse<_SmokeDto>> createPublic({
    required CreateDocDef<_SmokeDto> doc,
  }) => createDoc(doc: doc);

  /// Public wrapper over the protected [updateDoc].
  Future<TurboResponse<_SmokeDto>> updatePublic({
    required String id,
    required UpdateDocDef<_SmokeDto> doc,
  }) => updateDoc(id: id, doc: doc);

  /// Public wrapper over the protected [deleteDoc].
  Future<TurboResponse<void>> deletePublic({required String id}) =>
      deleteDoc(id: id);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TDummyFirestoreApi + TCollectionService smoke test', () {
    test(
      'Given a real TCollectionService subclass wired to a TDummyFirestoreApi, '
      'When seed → create → update → delete are performed via the service, '
      'Then the api stream re-emits correctly after each mutation',
      () async {
        const seedSize = 3;
        final api = TDummyFirestoreApi<_SmokeDto>(
          firebaseFirestore: FakeFirebaseFirestore(),
          collectionPath: () => 'smokeCollection',
          fromJson: _SmokeDto.fromJson,
          toJson: (dto) => dto.toJson(),
          seed: 42,
          dummyDelayDuration: Duration.zero,
          defaultCollectionSize: seedSize,
        );

        final service = _SmokeCollectionService(api: api);

        // Subscribe to the api stream and collect emissions.
        final emissions = <List<_SmokeDto>>[];
        final emissionCompleters = List.generate(
          4,
          (_) => Completer<void>(),
        );

        final sub = api.streamAllWithConverter().listen((data) {
          emissions.add(data);
          final idx = emissions.length - 1;
          if (idx < emissionCompleters.length &&
              !emissionCompleters[idx].isCompleted) {
            emissionCompleters[idx].complete();
          }
        });

        // -- Seed phase --
        await emissionCompleters[0].future.timeout(const Duration(seconds: 2));
        expect(emissions.length, 1, reason: 'First emission is the seed');
        expect(emissions[0].length, seedSize);

        // Hydrate the service's local state so update/delete can find docs.
        service.hydrateLocalState(emissions[0]);

        // -- Create phase --
        final createResult = await service.createPublic(
          doc: (vars) => _SmokeDto(
            id: vars.id,
            name: 'SmokeCreated',
            isActive: true,
          ),
        );

        expect(createResult.isSuccess, isTrue);
        final createdDto = createResult.result;
        expect(createdDto.name, 'SmokeCreated');

        // Allow async stream delivery.
        await Future<void>.delayed(Duration.zero);
        await emissionCompleters[1].future.timeout(const Duration(seconds: 2));

        expect(emissions.length, 2, reason: 'Second emission after create');
        expect(emissions[1].length, seedSize + 1);
        expect(
          emissions[1].any((e) => e.id == createdDto.id),
          isTrue,
          reason: 'Created entity is in the new emission',
        );

        // Hydrate the service's local state with the created entity.
        service.hydrateLocalState(emissions[1]);

        // -- Update phase --
        final updateResult = await service.updatePublic(
          id: createdDto.id,
          doc: (current, vars) => current.copyWith(name: 'SmokeUpdated'),
        );

        expect(updateResult.isSuccess, isTrue);
        expect(updateResult.result.name, 'SmokeUpdated');

        // Allow async stream delivery.
        await Future<void>.delayed(Duration.zero);
        await emissionCompleters[2].future.timeout(const Duration(seconds: 2));

        expect(emissions.length, 3, reason: 'Third emission after update');
        expect(
          emissions[2].length,
          seedSize + 1,
          reason: 'Collection size unchanged after update',
        );
        final updatedInStream = emissions[2].firstWhere(
          (e) => e.id == createdDto.id,
        );
        expect(updatedInStream.name, 'SmokeUpdated');

        // -- Delete phase --
        final deleteResult = await service.deletePublic(id: createdDto.id);

        expect(deleteResult.isSuccess, isTrue);

        // Allow async stream delivery.
        await Future<void>.delayed(Duration.zero);
        await emissionCompleters[3].future.timeout(const Duration(seconds: 2));

        expect(emissions.length, 4, reason: 'Fourth emission after delete');
        expect(emissions[3].length, seedSize);
        expect(
          emissions[3].any((e) => e.id == createdDto.id),
          isFalse,
          reason: 'Deleted entity is absent',
        );

        // Cleanup.
        await sub.cancel();
        await service.dispose();
        await api.dispose();
      },
    );

    test(
      'Given a service with initialiseStream: false (no Firebase Auth), '
      'When create → update → delete are called via the service, '
      'Then docsPerIdNotifier reflects the mutations at each step '
      'without manual hydration',
      () async {
        final api = TDummyFirestoreApi<_SmokeDto>(
          firebaseFirestore: FakeFirebaseFirestore(),
          collectionPath: () => 'notifierCollection',
          fromJson: _SmokeDto.fromJson,
          toJson: (dto) => dto.toJson(),
          seed: 42,
          dummyDelayDuration: Duration.zero,
          defaultCollectionSize: 0,
        );

        final service = _SmokeCollectionService(api: api);

        // Initial state: empty notifier.
        expect(service.docsPerId.value, isEmpty);

        // -- Create phase --
        final createResult = await service.createPublic(
          doc: (vars) => _SmokeDto(
            id: vars.id,
            name: 'NotifierTest',
            isActive: true,
          ),
        );
        expect(createResult.isSuccess, isTrue);
        final createdDto = createResult.result;

        // docsPerIdNotifier updated by createLocalDoc.
        expect(service.docsPerId.value.length, 1);
        expect(service.docsPerId.value[createdDto.id]?.name, 'NotifierTest');
        expect(service.hasDocs, isTrue);
        expect(service.exists(createdDto.id), isTrue);
        expect(service.findById(createdDto.id).name, 'NotifierTest');

        // -- Update phase --
        final updateResult = await service.updatePublic(
          id: createdDto.id,
          doc: (current, vars) => current.copyWith(name: 'Updated'),
        );
        expect(updateResult.isSuccess, isTrue);

        // docsPerIdNotifier reflects the update.
        expect(service.docsPerId.value[createdDto.id]?.name, 'Updated');
        expect(service.findById(createdDto.id).name, 'Updated');

        // -- Delete phase --
        final deleteResult = await service.deletePublic(id: createdDto.id);
        expect(deleteResult.isSuccess, isTrue);

        // docsPerIdNotifier empty again.
        expect(service.docsPerId.value, isEmpty);
        expect(service.hasDocs, isFalse);
        expect(service.exists(createdDto.id), isFalse);
        expect(service.tryFindById(createdDto.id), isNull);

        // Cleanup.
        await service.dispose();
        await api.dispose();
      },
    );
  });
}
