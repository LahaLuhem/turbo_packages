import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/abstracts/i_firestore_cache_service.dart';
import 'package:turbo_firestore_api/dtos/t_cached_query.dart';

class _FakeFirestoreCacheService extends IFirestoreCacheService {
  final Map<String, Map<String, dynamic>> store = {};
  final List<String> deletedIds = [];

  @override
  FutureOr<void> write(String id, Map<String, dynamic> object) {
    store[id] = object;
  }

  @override
  FutureOr<Map<String, dynamic>?> read(String id) => store[id];

  @override
  FutureOr<void> delete(String id) {
    deletedIds.add(id);
    store.remove(id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TFirestoreCache.isValid - duration mode', () {
    final cache = TFirestoreCache(
      firestoreCacheService: _FakeFirestoreCacheService(),
      cacheInvalidationDuration: const Duration(hours: 1),
    );

    test('returns true when cached within duration', () {
      final now = DateTime(2026, 4, 29, 12, 0);
      final cachedAt = now.subtract(const Duration(minutes: 30));
      expect(cache.isValid(now: now, cachedAt: cachedAt), isTrue);
    });

    test('returns false when cached exactly at duration boundary', () {
      final now = DateTime(2026, 4, 29, 12, 0);
      final cachedAt = now.subtract(const Duration(hours: 1));
      expect(cache.isValid(now: now, cachedAt: cachedAt), isFalse);
    });

    test('returns false when cached older than duration', () {
      final now = DateTime(2026, 4, 29, 12, 0);
      final cachedAt = now.subtract(const Duration(hours: 2));
      expect(cache.isValid(now: now, cachedAt: cachedAt), isFalse);
    });
  });

  group('TFirestoreCache.isValid - weekday/time mode (default Monday 04:00)', () {
    final cache = TFirestoreCache(
      firestoreCacheService: _FakeFirestoreCacheService(),
    );

    // Calendar reference (Gregorian):
    //   Mon 2026-04-27, Tue 2026-04-28, Wed 2026-04-29, Sun 2026-05-03,
    //   Mon 2026-05-04.

    test('valid: cached just after last Monday 04:00, now mid-week', () {
      final now = DateTime(2026, 4, 29, 14, 0); // Wed
      final cachedAt = DateTime(2026, 4, 27, 4, 0, 1); // Mon 04:00:01
      expect(cache.isValid(now: now, cachedAt: cachedAt), isTrue);
    });

    test('invalid: cached before last Monday 04:00 boundary', () {
      final now = DateTime(2026, 4, 29, 14, 0); // Wed
      final cachedAt = DateTime(2026, 4, 27, 3, 59); // Mon 03:59 — before boundary
      expect(cache.isValid(now: now, cachedAt: cachedAt), isFalse);
    });

    test('invalid: cached previous week', () {
      final now = DateTime(2026, 4, 29, 14, 0); // Wed
      final cachedAt = DateTime(2026, 4, 22, 12, 0); // prev Wed
      expect(cache.isValid(now: now, cachedAt: cachedAt), isFalse);
    });

    test('Sunday before next Monday 04:00 uses previous Monday boundary', () {
      final now = DateTime(2026, 5, 3, 23, 0); // Sun
      final cachedAtValid = DateTime(2026, 4, 27, 5, 0); // last Mon 05:00
      final cachedAtInvalid = DateTime(2026, 4, 27, 3, 0); // last Mon 03:00
      expect(cache.isValid(now: now, cachedAt: cachedAtValid), isTrue);
      expect(cache.isValid(now: now, cachedAt: cachedAtInvalid), isFalse);
    });

    test('Monday before 04:00 uses PREVIOUS Monday as boundary', () {
      final now = DateTime(2026, 5, 4, 3, 30); // Mon 03:30
      final cachedAtAfterPrev = DateTime(2026, 4, 27, 5, 0); // prev Mon 05:00
      final cachedAtBeforePrev = DateTime(2026, 4, 27, 3, 0); // prev Mon 03:00
      expect(cache.isValid(now: now, cachedAt: cachedAtAfterPrev), isTrue);
      expect(cache.isValid(now: now, cachedAt: cachedAtBeforePrev), isFalse);
    });

    test('Monday at/after 04:00 rolls boundary to current Monday', () {
      final now = DateTime(2026, 5, 4, 4, 30); // Mon 04:30
      final cachedJustAfterBoundary = DateTime(2026, 5, 4, 4, 0, 1); // Mon 04:00:01
      final cachedJustBeforeBoundary = DateTime(2026, 5, 4, 3, 59, 59); // Mon 03:59:59
      expect(cache.isValid(now: now, cachedAt: cachedJustAfterBoundary), isTrue);
      expect(cache.isValid(now: now, cachedAt: cachedJustBeforeBoundary), isFalse);
    });

    test('regression: does NOT invalidate every day past 04:00', () {
      // Pre-fix bug wiped cache daily once now > 04:00. Verify mid-week reads
      // of a Monday-cached entry remain valid.
      final cachedAt = DateTime(2026, 4, 27, 10, 0); // Mon 10:00
      for (final day in [28, 29, 30]) {
        for (final hour in [5, 12, 23]) {
          final now = DateTime(2026, 4, day, hour, 0);
          expect(
            cache.isValid(now: now, cachedAt: cachedAt),
            isTrue,
            reason: 'Should be valid at ${now.toIso8601String()}',
          );
        }
      }
    });
  });

  group('TFirestoreCache.isValid - custom weekday/time', () {
    test('Friday 06:00 boundary', () {
      final cache = TFirestoreCache(
        firestoreCacheService: _FakeFirestoreCacheService(),
        cacheInvalidationTime: const TimeOfDay(hour: 6, minute: 0),
        cacheInvalidationWeekday: DateTime.friday,
      );
      // Fri 2026-05-01, Sat 2026-05-02.
      final now = DateTime(2026, 5, 2, 12, 0); // Sat
      expect(
        cache.isValid(now: now, cachedAt: DateTime(2026, 5, 1, 6, 1)),
        isTrue,
      );
      expect(
        cache.isValid(now: now, cachedAt: DateTime(2026, 5, 1, 5, 59)),
        isFalse,
      );
    });
  });

  group('TFirestoreCache.get / list integration', () {
    late _FakeFirestoreCacheService service;
    late TFirestoreCache cache;

    setUp(() {
      service = _FakeFirestoreCacheService();
      cache = TFirestoreCache(
        firestoreCacheService: service,
        cacheInvalidationDuration: const Duration(hours: 1),
      );
    });

    test('saveDoc then get returns the doc when fresh', () async {
      await cache.saveDoc(docId: 'd1', path: 'col', doc: {'a': 1});
      final got = await cache.get(path: 'col', id: 'd1');
      expect(got, {'a': 1});
      expect(service.deletedIds, isEmpty);
    });

    test('get deletes and returns null when expired', () async {
      final stale = TCachedQuery(
        query: 'd1@col',
        doc: {'a': 1},
        docs: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      await service.writeCachedQuery(cachedQuery: stale);

      final got = await cache.get(path: 'col', id: 'd1');
      expect(got, isNull);
      expect(service.deletedIds, contains('d1@col'));
    });

    test('saveDocs then list returns docs when fresh', () async {
      await cache.saveDocs(
        query: 'q1',
        path: 'col',
        docs: [
          {'a': 1},
          {'b': 2},
        ],
      );
      final got = await cache.list(path: 'col', query: 'q1');
      expect(got, [
        {'a': 1},
        {'b': 2},
      ]);
      expect(service.deletedIds, isEmpty);
    });

    test('list deletes and returns null when expired', () async {
      final stale = TCachedQuery(
        query: 'q1@col',
        doc: null,
        docs: [
          {'a': 1},
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      await service.writeCachedQuery(cachedQuery: stale);

      final got = await cache.list(path: 'col', query: 'q1');
      expect(got, isNull);
      expect(service.deletedIds, contains('q1@col'));
    });

    test('get returns null when no entry exists (no delete)', () async {
      final got = await cache.get(path: 'col', id: 'missing');
      expect(got, isNull);
      expect(service.deletedIds, isEmpty);
    });
  });
}
