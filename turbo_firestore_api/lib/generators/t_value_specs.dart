import 'dart:math';

import 'package:turbo_firestore_api/generators/t_value_generator.dart';

/// Internal lorem word pool for text generation factories.
const List<String> _loremWords = [
  'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing',
  'elit', 'sed', 'do', 'eiusmod', 'tempor', 'incididunt', 'ut', 'labore',
  'et', 'dolore', 'magna', 'aliqua', 'enim', 'ad', 'minim', 'veniam',
  'quis', 'nostrud', 'exercitation', 'ullamco', 'laboris', 'nisi',
  'aliquip', 'ex', 'ea', 'commodo', 'consequat',
];

/// Deterministic time anchor for date factories.
final DateTime _anchor = DateTime.utc(2025);

// ---------------------------------------------------------------------------
// Validation helpers
// ---------------------------------------------------------------------------

void _requireNonEmpty<V>(List<V> values, String name) {
  if (values.isEmpty) {
    throw ArgumentError.value(values, name, 'must not be empty');
  }
}

void _requireMinLessThanMax<T extends num>(T min, T max) {
  if (max <= min) {
    throw ArgumentError('max ($max) must be greater than min ($min)');
  }
}

void _requirePositive(int value, String name) {
  if (value < 1) {
    throw ArgumentError.value(value, name, 'must be >= 1');
  }
}

void _requireNonNegativeDuration(Duration within) {
  if (within.isNegative) {
    throw ArgumentError.value(within, 'within', 'must not be negative');
  }
}

// ---------------------------------------------------------------------------
// Text helpers
// ---------------------------------------------------------------------------

String _generateWords(Random random, int count) {
  return List.generate(
    count,
    (_) => _loremWords[random.nextInt(_loremWords.length)],
  ).join(' ');
}

// ---------------------------------------------------------------------------
// Public factories
// ---------------------------------------------------------------------------

/// Returns a generator that picks a random element from [values] on each call.
///
/// Throws [ArgumentError] if [values] is empty.
TValueGenerator oneOf<V>(
  List<V> values, {
  required Random random,
}) {
  _requireNonEmpty(values, 'values');
  return () => values[random.nextInt(values.length)];
}

/// Returns a generator that picks a random enum value from [values] on each
/// call.
///
/// Throws [ArgumentError] if [values] is empty.
TValueGenerator oneOfEnum<E extends Enum>(
  List<E> values, {
  required Random random,
}) {
  _requireNonEmpty(values, 'values');
  return () => values[random.nextInt(values.length)];
}

/// Returns a generator that produces a random int in `[min, max)` on each
/// call.
///
/// Throws [ArgumentError] if [max] is not greater than [min].
TValueGenerator rangeInt(
  int min,
  int max, {
  required Random random,
}) {
  _requireMinLessThanMax(min, max);
  return () => min + random.nextInt(max - min);
}

/// Returns a generator that produces a random double in `[min, max)` on each
/// call.
///
/// Throws [ArgumentError] if [max] is not greater than [min].
TValueGenerator rangeDouble(
  double min,
  double max, {
  required Random random,
}) {
  _requireMinLessThanMax(min, max);
  return () => min + (random.nextDouble() * (max - min));
}

/// Returns a generator that produces a lowercase lorem sentence of
/// [wordCount] words on each call.
///
/// Throws [ArgumentError] if [wordCount] is less than 1.
TValueGenerator sentence({
  required Random random,
  int wordCount = 8,
}) {
  _requirePositive(wordCount, 'wordCount');
  return () => _generateWords(random, wordCount);
}

/// Returns a generator that produces between [min] and [max] (inclusive)
/// lowercase lorem words joined by a space on each call.
///
/// Throws [ArgumentError] if [min] is less than 1 or [max] is less than
/// [min].
TValueGenerator words({
  required Random random,
  int min = 1,
  int max = 3,
}) {
  _requirePositive(min, 'min');
  if (max < min) {
    throw ArgumentError('max ($max) must be >= min ($min)');
  }
  return () {
    final count = min == max ? min : min + random.nextInt(max - min + 1);
    return _generateWords(random, count);
  };
}

/// Returns a generator that produces a paragraph of [sentences] sentences on
/// each call.
///
/// Each sentence contains 8 lowercase lorem words. Sentences are joined by
/// `'. '` and the paragraph ends with `'.'`.
///
/// Throws [ArgumentError] if [sentences] is less than 1.
TValueGenerator paragraph({
  required Random random,
  int sentences = 3,
}) {
  _requirePositive(sentences, 'sentences');
  return () {
    final parts = List.generate(
      sentences,
      (_) => _generateWords(random, 8),
    );
    return '${parts.join('. ')}.';
  };
}

/// Returns a generator that produces a [DateTime] before a deterministic
/// anchor (`DateTime.utc(2025)`) within the given [within] duration on each
/// call.
///
/// Throws [ArgumentError] if [within] is negative.
TValueGenerator pastDate({
  required Random random,
  Duration within = const Duration(days: 365),
}) {
  _requireNonNegativeDuration(within);
  final totalMs = within.inMilliseconds;
  return () {
    if (totalMs == 0) return _anchor;
    final offsetMs = (random.nextDouble() * totalMs).toInt() + 1;
    return _anchor.subtract(Duration(milliseconds: offsetMs));
  };
}

/// Returns a generator that produces a [DateTime] after a deterministic
/// anchor (`DateTime.utc(2025)`) within the given [within] duration on each
/// call.
///
/// Throws [ArgumentError] if [within] is negative.
TValueGenerator futureDate({
  required Random random,
  Duration within = const Duration(days: 365),
}) {
  _requireNonNegativeDuration(within);
  final totalMs = within.inMilliseconds;
  return () {
    if (totalMs == 0) return _anchor;
    final offsetMs = (random.nextDouble() * totalMs).toInt() + 1;
    return _anchor.add(Duration(milliseconds: offsetMs));
  };
}

/// Returns a generator that produces deterministic pseudo-ids with a
/// monotonically increasing counter.
///
/// Each call returns `'dummy_'` followed by a zero-padded 8-digit index.
/// Each `uuid()` invocation creates an independent counter sequence starting
/// at zero.
TValueGenerator uuid() {
  var counter = 0;
  return () => 'dummy_${(counter++).toString().padLeft(8, '0')}';
}

/// Returns a generator that always returns the exact supplied [value].
TValueGenerator fixed<V>(V value) {
  return () => value;
}
