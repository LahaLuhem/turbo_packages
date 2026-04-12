import 'dart:math';

import 'package:test/test.dart';
import 'package:turbo_firestore_api/generators/t_value_specs.dart';

enum _TestStatus { draft, active, archived }

/// Deterministic anchor matching the production code.
final DateTime _anchor = DateTime.utc(2025);

void main() {
  group('t_value_specs', () {
    // -----------------------------------------------------------------------
    // oneOf
    // -----------------------------------------------------------------------

    test(
      'Given oneOf with three values, '
      'When called 100 times, '
      'Then every result is one of the supplied values',
      () {
        final gen = oneOf([1, 2, 3], random: Random(0));

        for (var i = 0; i < 100; i++) {
          final result = gen();
          expect(result, isIn([1, 2, 3]));
        }
      },
    );

    test(
      'Given oneOf with an empty list, '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => oneOf<int>([], random: Random(0)),
          throwsArgumentError,
        );
      },
    );

    // -----------------------------------------------------------------------
    // oneOfEnum
    // -----------------------------------------------------------------------

    test(
      'Given oneOfEnum with TestStatus values, '
      'When called 100 times, '
      'Then every result is one of the enum values',
      () {
        final gen = oneOfEnum(
          _TestStatus.values,
          random: Random(0),
        );

        for (var i = 0; i < 100; i++) {
          final result = gen();
          expect(result, isA<_TestStatus>());
          expect(_TestStatus.values, contains(result));
        }
      },
    );

    test(
      'Given oneOfEnum with an empty list, '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => oneOfEnum<_TestStatus>([], random: Random(0)),
          throwsArgumentError,
        );
      },
    );

    // -----------------------------------------------------------------------
    // rangeInt
    // -----------------------------------------------------------------------

    test(
      'Given rangeInt(10, 20), '
      'When called 100 times, '
      'Then every result is in [10, 20)',
      () {
        final gen = rangeInt(10, 20, random: Random(0));

        for (var i = 0; i < 100; i++) {
          final result = gen() as int;
          expect(result, greaterThanOrEqualTo(10));
          expect(result, lessThan(20));
        }
      },
    );

    test(
      'Given rangeInt(20, 10), '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => rangeInt(20, 10, random: Random(0)),
          throwsArgumentError,
        );
      },
    );

    // -----------------------------------------------------------------------
    // rangeDouble
    // -----------------------------------------------------------------------

    test(
      'Given rangeDouble(1.5, 3.5), '
      'When called 100 times, '
      'Then every result is in [1.5, 3.5)',
      () {
        final gen = rangeDouble(1.5, 3.5, random: Random(0));

        for (var i = 0; i < 100; i++) {
          final result = gen() as double;
          expect(result, greaterThanOrEqualTo(1.5));
          expect(result, lessThan(3.5));
        }
      },
    );

    test(
      'Given rangeDouble(5.0, 5.0), '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => rangeDouble(5.0, 5.0, random: Random(0)),
          throwsArgumentError,
        );
      },
    );

    // -----------------------------------------------------------------------
    // sentence
    // -----------------------------------------------------------------------

    test(
      'Given sentence with wordCount 5, '
      'When called, '
      'Then the result has exactly 5 space-delimited lowercase words',
      () {
        final gen = sentence(random: Random(0), wordCount: 5);
        final result = gen() as String;
        final tokens = result.split(' ');

        expect(tokens.length, 5);
        expect(result, result.toLowerCase());
        expect(result.trim(), result);
      },
    );

    test(
      'Given sentence with wordCount 0, '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => sentence(random: Random(0), wordCount: 0),
          throwsArgumentError,
        );
      },
    );

    // -----------------------------------------------------------------------
    // words
    // -----------------------------------------------------------------------

    test(
      'Given words with min 2 and max 4, '
      'When called 100 times, '
      'Then each result has between 2 and 4 words inclusive',
      () {
        final gen = words(random: Random(0), min: 2, max: 4);

        for (var i = 0; i < 100; i++) {
          final result = gen() as String;
          final tokenCount = result.split(' ').length;
          expect(tokenCount, greaterThanOrEqualTo(2));
          expect(tokenCount, lessThanOrEqualTo(4));
        }
      },
    );

    test(
      'Given words with min 0, '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => words(random: Random(0), min: 0, max: 3),
          throwsArgumentError,
        );
      },
    );

    test(
      'Given words with max less than min, '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => words(random: Random(0), min: 4, max: 3),
          throwsArgumentError,
        );
      },
    );

    // -----------------------------------------------------------------------
    // paragraph
    // -----------------------------------------------------------------------

    test(
      'Given paragraph with 3 sentences, '
      'When called, '
      'Then the result ends with a period and contains 3 sentence segments',
      () {
        final gen = paragraph(random: Random(0), sentences: 3);
        final result = gen() as String;

        expect(result.endsWith('.'), isTrue);

        // Remove trailing dot, split by '. '
        final withoutFinalDot = result.substring(0, result.length - 1);
        final segments = withoutFinalDot.split('. ');
        expect(segments.length, 3);

        for (final segment in segments) {
          expect(segment.trim(), isNotEmpty);
          expect(segment, segment.toLowerCase());
        }
      },
    );

    test(
      'Given paragraph with 0 sentences, '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => paragraph(random: Random(0), sentences: 0),
          throwsArgumentError,
        );
      },
    );

    // -----------------------------------------------------------------------
    // pastDate
    // -----------------------------------------------------------------------

    test(
      'Given pastDate with within 30 days, '
      'When called 100 times, '
      'Then every result is between anchor-30d and anchor inclusive',
      () {
        const within = Duration(days: 30);
        final gen = pastDate(random: Random(0), within: within);
        final lowerBound = _anchor.subtract(within);

        for (var i = 0; i < 100; i++) {
          final result = gen() as DateTime;
          expect(
            result.millisecondsSinceEpoch,
            greaterThanOrEqualTo(lowerBound.millisecondsSinceEpoch),
          );
          expect(
            result.millisecondsSinceEpoch,
            lessThanOrEqualTo(_anchor.millisecondsSinceEpoch),
          );
        }
      },
    );

    test(
      'Given pastDate with negative duration, '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => pastDate(
            random: Random(0),
            within: const Duration(days: -1),
          ),
          throwsArgumentError,
        );
      },
    );

    // -----------------------------------------------------------------------
    // futureDate
    // -----------------------------------------------------------------------

    test(
      'Given futureDate with within 30 days, '
      'When called 100 times, '
      'Then every result is between anchor and anchor+30d inclusive',
      () {
        const within = Duration(days: 30);
        final gen = futureDate(random: Random(0), within: within);
        final upperBound = _anchor.add(within);

        for (var i = 0; i < 100; i++) {
          final result = gen() as DateTime;
          expect(
            result.millisecondsSinceEpoch,
            greaterThanOrEqualTo(_anchor.millisecondsSinceEpoch),
          );
          expect(
            result.millisecondsSinceEpoch,
            lessThanOrEqualTo(upperBound.millisecondsSinceEpoch),
          );
        }
      },
    );

    test(
      'Given futureDate with negative duration, '
      'When constructed, '
      'Then it throws ArgumentError',
      () {
        expect(
          () => futureDate(
            random: Random(0),
            within: const Duration(days: -1),
          ),
          throwsArgumentError,
        );
      },
    );

    // -----------------------------------------------------------------------
    // uuid
    // -----------------------------------------------------------------------

    test(
      'Given a uuid generator, '
      'When called several times, '
      'Then outputs are sequential zero-padded ids',
      () {
        final gen = uuid();

        expect(gen(), 'dummy_00000000');
        expect(gen(), 'dummy_00000001');
        expect(gen(), 'dummy_00000002');
        expect(gen(), 'dummy_00000003');
      },
    );

    test(
      'Given two uuid generators, '
      'When each is called, '
      'Then they maintain independent counters',
      () {
        final genA = uuid();
        final genB = uuid();

        expect(genA(), 'dummy_00000000');
        expect(genA(), 'dummy_00000001');
        expect(genB(), 'dummy_00000000');
        expect(genB(), 'dummy_00000001');
      },
    );

    // -----------------------------------------------------------------------
    // fixed
    // -----------------------------------------------------------------------

    test(
      'Given fixed(42), '
      'When called 10 times, '
      'Then every call returns 42',
      () {
        final gen = fixed(42);

        for (var i = 0; i < 10; i++) {
          expect(gen(), 42);
        }
      },
    );

    test(
      'Given fixed with a string value, '
      'When called repeatedly, '
      'Then every call returns the same string',
      () {
        final gen = fixed('pinned');

        for (var i = 0; i < 10; i++) {
          expect(gen(), 'pinned');
        }
      },
    );

    // -----------------------------------------------------------------------
    // Determinism
    // -----------------------------------------------------------------------

    test(
      'Given two factory chains built with Random(42), '
      'When each is walked in the same order, '
      'Then their outputs are element-wise equal',
      () {
        final rngA = Random(42);
        final rngB = Random(42);

        // Build parallel factory chains.
        final oneOfA = oneOf([1, 2, 3], random: rngA);
        final oneOfB = oneOf([1, 2, 3], random: rngB);

        final enumA = oneOfEnum(
          _TestStatus.values,
          random: rngA,
        );
        final enumB = oneOfEnum(
          _TestStatus.values,
          random: rngB,
        );

        final intA = rangeInt(0, 100, random: rngA);
        final intB = rangeInt(0, 100, random: rngB);

        final doubleA = rangeDouble(0, 100, random: rngA);
        final doubleB = rangeDouble(0, 100, random: rngB);

        final sentA = sentence(random: rngA, wordCount: 5);
        final sentB = sentence(random: rngB, wordCount: 5);

        final wordsA = words(random: rngA, min: 2, max: 4);
        final wordsB = words(random: rngB, min: 2, max: 4);

        final paraA = paragraph(random: rngA, sentences: 2);
        final paraB = paragraph(random: rngB, sentences: 2);

        final pastA = pastDate(random: rngA);
        final pastB = pastDate(random: rngB);

        final futureA = futureDate(random: rngA);
        final futureB = futureDate(random: rngB);

        final uuidA = uuid();
        final uuidB = uuid();

        // Invoke in identical order and compare.
        for (var i = 0; i < 10; i++) {
          expect(oneOfA(), oneOfB(), reason: 'oneOf mismatch at $i');
          expect(enumA(), enumB(), reason: 'oneOfEnum mismatch at $i');
          expect(intA(), intB(), reason: 'rangeInt mismatch at $i');
          expect(doubleA(), doubleB(), reason: 'rangeDouble mismatch at $i');
          expect(sentA(), sentB(), reason: 'sentence mismatch at $i');
          expect(wordsA(), wordsB(), reason: 'words mismatch at $i');
          expect(paraA(), paraB(), reason: 'paragraph mismatch at $i');

          final pA = pastA() as DateTime;
          final pB = pastB() as DateTime;
          expect(
            pA.millisecondsSinceEpoch,
            pB.millisecondsSinceEpoch,
            reason: 'pastDate mismatch at $i',
          );

          final fA = futureA() as DateTime;
          final fB = futureB() as DateTime;
          expect(
            fA.millisecondsSinceEpoch,
            fB.millisecondsSinceEpoch,
            reason: 'futureDate mismatch at $i',
          );

          expect(uuidA(), uuidB(), reason: 'uuid mismatch at $i');
        }
      },
    );
  });
}
