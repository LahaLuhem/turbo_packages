import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/apis/t_dummy_firestore_api.dart';
import 'package:turbo_firestore_api/enums/t_search_term_type.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';

// ---------------------------------------------------------------------------
// Synthetic fixture DTO
// ---------------------------------------------------------------------------

class _QueryDto extends TWriteable {
  _QueryDto({
    required this.id,
    required this.name,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory _QueryDto.fromJson(Map<String, dynamic> json) => _QueryDto(
    id: json['id'] as String,
    name: json['name'] as String,
    status: json['status'] as String,
    createdAt: json['createdAt'] as Timestamp?,
    updatedAt: json['updatedAt'] as Timestamp?,
  );

  final String id;
  final String name;
  final String status;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!,
      if (updatedAt != null) 'updatedAt': updatedAt!,
    };
  }
}

/// A DTO with no `name` field for graceful-degradation testing.
class _NoNameDto extends TWriteable {
  _NoNameDto({
    required this.id,
    required this.code,
  });

  factory _NoNameDto.fromJson(Map<String, dynamic> json) => _NoNameDto(
    id: json['id'] as String,
    code: json['code'] as int,
  );

  final String id;
  final int code;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
    };
  }
}

// ---------------------------------------------------------------------------
// Synthetic writeables
// ---------------------------------------------------------------------------

class _CreateQueryWriteable extends TWriteable {
  _CreateQueryWriteable({
    required this.name,
    required this.status,
  });

  final String name;
  final String status;

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'status': status,
  };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TDummyFirestoreApi<_QueryDto> _createQueryApi({
  int? seed,
  Map<String, bool Function(Map<String, dynamic>)>? queryFilters,
  Map<String, int Function(Map<String, dynamic>, Map<String, dynamic>)>?
  querySort,
  String searchField = 'name',
  int defaultCollectionSize = 0,
}) => TDummyFirestoreApi<_QueryDto>(
  firebaseFirestore: FakeFirebaseFirestore(),
  collectionPath: () => 'queryCollection',
  fromJson: _QueryDto.fromJson,
  toJson: null,
  seed: seed,
  dummyDelayDuration: Duration.zero,
  defaultCollectionSize: defaultCollectionSize,
  queryFilters: queryFilters,
  querySort: querySort,
  searchField: searchField,
);

TDummyFirestoreApi<_NoNameDto> _createNoNameApi({
  int? seed,
  int defaultCollectionSize = 0,
}) => TDummyFirestoreApi<_NoNameDto>(
  firebaseFirestore: FakeFirebaseFirestore(),
  collectionPath: () => 'noNameCollection',
  fromJson: _NoNameDto.fromJson,
  toJson: null,
  seed: seed,
  dummyDelayDuration: Duration.zero,
  defaultCollectionSize: defaultCollectionSize,
);

void _seedRawStore(
  TDummyFirestoreApi api,
  List<Map<String, dynamic>> docs,
) {
  final store = dummyStoreForTesting(api);
  for (final doc in docs) {
    store[doc['id'] as String] = Map<String, dynamic>.of(doc);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TDummyFirestoreApi query filter and sort', () {
    test(
      'Given queryFilters with an "active" predicate, '
      'When listByQueryWithConverter is called with whereDescription "active", '
      'Then only active entities are returned',
      () async {
        final api = _createQueryApi(
          seed: 42,
          queryFilters: {
            'active': (doc) => doc['status'] == 'active',
          },
        );

        _seedRawStore(api, [
          {
            'id': 'a',
            'name': 'Alice',
            'status': 'active',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
          },
          {
            'id': 'b',
            'name': 'Bob',
            'status': 'archived',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 2)),
          },
          {
            'id': 'c',
            'name': 'Charlie',
            'status': 'active',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 3)),
          },
        ]);

        final response = await api.listByQueryWithConverter(
          collectionReferenceQuery: (ref) => ref,
          whereDescription: 'active',
        );

        expect(response.isSuccess, isTrue);
        final results = response.result;
        expect(results.length, 2);
        expect(results[0].id, 'a');
        expect(results[1].id, 'c');
      },
    );

    test(
      'Given queryFilters and querySort with an "active" key, '
      'When listByQueryWithConverter is called with whereDescription "active", '
      'Then active entities are returned sorted by createdAt ascending',
      () async {
        final api = _createQueryApi(
          seed: 42,
          queryFilters: {
            'active': (doc) => doc['status'] == 'active',
          },
          querySort: {
            'active': (a, b) => (a['createdAt'] as Timestamp).compareTo(
              b['createdAt'] as Timestamp,
            ),
          },
        );

        _seedRawStore(api, [
          {
            'id': 'c',
            'name': 'Charlie',
            'status': 'active',
            'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
          },
          {
            'id': 'a',
            'name': 'Alice',
            'status': 'active',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
          },
          {
            'id': 'b',
            'name': 'Bob',
            'status': 'archived',
            'createdAt': Timestamp.fromDate(DateTime(2025, 2, 1)),
          },
        ]);

        final response = await api.listByQueryWithConverter(
          collectionReferenceQuery: (ref) => ref,
          whereDescription: 'active',
        );

        expect(response.isSuccess, isTrue);
        final results = response.result;
        expect(results.length, 2);
        expect(results[0].id, 'a');
        expect(results[1].id, 'c');
      },
    );

    test(
      'Given no registered filter or sort for "unknown", '
      'When listByQueryWithConverter is called with whereDescription "unknown", '
      'Then the entire seeded store is returned in original order',
      () async {
        final api = _createQueryApi(seed: 42);

        _seedRawStore(api, [
          {
            'id': 'x',
            'name': 'Xena',
            'status': 'active',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
          },
          {
            'id': 'y',
            'name': 'Yuri',
            'status': 'archived',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 2)),
          },
        ]);

        final response = await api.listByQueryWithConverter(
          collectionReferenceQuery: (ref) => ref,
          whereDescription: 'unknown',
        );

        expect(response.isSuccess, isTrue);
        final results = response.result;
        expect(results.length, 2);
        expect(results[0].id, 'x');
        expect(results[1].id, 'y');
      },
    );

    test(
      'Given a subscribed streamByQueryWithConverter with "active" filter and sort, '
      'When a new active entity is created, '
      'Then the next emission includes it in the correct sorted position',
      () async {
        final api = _createQueryApi(
          seed: 42,
          queryFilters: {
            'active': (doc) => doc['status'] == 'active',
          },
          querySort: {
            'active': (a, b) => (a['createdAt'] as Timestamp).compareTo(
              b['createdAt'] as Timestamp,
            ),
          },
        );

        // Seed with one active entity.
        _seedRawStore(api, [
          {
            'id': 'a',
            'name': 'Alice',
            'status': 'active',
            'createdAt': Timestamp.fromDate(DateTime(2025, 6, 1)),
          },
        ]);

        final stream = api.streamByQueryWithConverter(
          whereDescription: 'active',
        );

        // Await initial emission.
        final initial = await stream.first;
        expect(initial.length, 1);

        // Listen for the next emission after a write.
        final nextEmission = stream.first;

        // Create a new active entity.
        await api.createDoc(
          writeable: _CreateQueryWriteable(name: 'Eve', status: 'active'),
        );

        final latest = await nextEmission;
        expect(latest.length, 2);
        // Eve's createdAt is set by createDoc (now()), which is after Alice's,
        // so Alice comes first.
        expect(latest[0].id, 'a');
        expect(latest[1].name, 'Eve');
      },
    );

    test(
      'Given a subscribed streamByQueryWithConverter with "active" filter, '
      'When an inactive entity is created, '
      'Then the next emission does NOT include the new entity',
      () async {
        final api = _createQueryApi(
          seed: 42,
          queryFilters: {
            'active': (doc) => doc['status'] == 'active',
          },
        );

        _seedRawStore(api, [
          {
            'id': 'a',
            'name': 'Alice',
            'status': 'active',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
          },
        ]);

        final stream = api.streamByQueryWithConverter(
          whereDescription: 'active',
        );

        // Await initial emission.
        final initial = await stream.first;
        expect(initial.length, 1);

        // Listen for the next emission after a write.
        final nextEmission = stream.first;

        // Create an inactive entity.
        await api.createDoc(
          writeable: _CreateQueryWriteable(name: 'Zara', status: 'archived'),
        );

        final latest = await nextEmission;
        // The inactive entity must not appear in the active stream.
        expect(latest.length, 1);
        expect(latest[0].id, 'a');
      },
    );

    test(
      'Given no registered filter and default searchField "name", '
      'When listBySearchTermWithConverter is called with searchTerm "ali", '
      'Then only entities whose name contains "ali" (case-insensitive) are returned',
      () async {
        final api = _createQueryApi(seed: 42);

        _seedRawStore(api, [
          {
            'id': 'a',
            'name': 'Alice',
            'status': 'active',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
          },
          {
            'id': 'b',
            'name': 'Bob',
            'status': 'active',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 2)),
          },
          {
            'id': 'c',
            'name': 'Alicia',
            'status': 'archived',
            'createdAt': Timestamp.fromDate(DateTime(2025, 1, 3)),
          },
        ]);

        final response = await api.listBySearchTermWithConverter(
          searchTerm: 'ali',
          searchField: 'name',
          searchTermType: TSearchTermType.startsWith,
        );

        expect(response.isSuccess, isTrue);
        final results = response.result;
        expect(results.length, 2);
        expect(results[0].name, 'Alice');
        expect(results[1].name, 'Alicia');
      },
    );

    test(
      'Given a DTO with no "name" field, '
      'When listBySearchTermWithConverter is called with searchField "name", '
      'Then the full store is returned without crashing (graceful degradation)',
      () async {
        final api = _createNoNameApi(seed: 42);

        final store = dummyStoreForTesting(api);
        store['x'] = {'id': 'x', 'code': 42};
        store['y'] = {'id': 'y', 'code': 99};

        final response = await api.listBySearchTermWithConverter(
          searchTerm: 'anything',
          searchField: 'name',
          searchTermType: TSearchTermType.startsWith,
        );

        expect(response.isSuccess, isTrue);
        final results = response.result;
        expect(
          results.length,
          0,
          reason: 'Documents without the search field are filtered out',
        );
      },
    );
  });
}
