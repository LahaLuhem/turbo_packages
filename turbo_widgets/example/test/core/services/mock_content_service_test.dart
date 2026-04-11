import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets_example/core/services/mock_content_service.dart';

void main() {
  late MockContentService sut;

  setUp(() {
    sut = MockContentService();
  });

  group('GIVEN a MockContentService', () {
    group('WHEN accessing categories', () {
      test('THEN it returns a non-empty list', () {
        expect(sut.categories, isNotEmpty);
      });

      test('THEN every category has a non-empty title', () {
        for (final cat in sut.categories) {
          expect(cat.title, isNotEmpty);
        }
      });

      test('THEN every category has a non-empty subtitle', () {
        for (final cat in sut.categories) {
          expect(cat.subtitle, isNotEmpty);
        }
      });
    });

    group('WHEN accessing collectionItems', () {
      test('THEN it returns a non-empty list', () {
        expect(sut.collectionItems, isNotEmpty);
      });

      test('THEN every item has a non-empty title', () {
        for (final item in sut.collectionItems) {
          expect(item.title, isNotEmpty);
        }
      });

      test('THEN every item has a non-empty description', () {
        for (final item in sut.collectionItems) {
          expect(item.description, isNotEmpty);
        }
      });
    });

    group('WHEN accessing plans', () {
      test('THEN it returns a non-empty list', () {
        expect(sut.plans, isNotEmpty);
      });

      test('THEN every plan has a non-empty title', () {
        for (final plan in sut.plans) {
          expect(plan.title, isNotEmpty);
        }
      });
    });

    group('WHEN accessing metadataFields', () {
      test('THEN it returns a non-empty list', () {
        expect(sut.metadataFields, isNotEmpty);
      });

      test('THEN every field has a non-empty label and value', () {
        for (final field in sut.metadataFields) {
          expect(field.label, isNotEmpty);
          expect(field.value, isNotEmpty);
        }
      });
    });

    group('WHEN calling markdownContent', () {
      test('THEN known keys return non-empty content', () {
        expect(sut.markdownContent('usage'), isNotEmpty);
        expect(sut.markdownContent('overview'), isNotEmpty);
      });

      test('THEN unknown keys return fallback content', () {
        final result = sut.markdownContent('anything');
        expect(result, isNotEmpty);
        expect(result, contains('anything'));
      });
    });
  });
}
