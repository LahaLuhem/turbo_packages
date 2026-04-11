import 'package:flutter_test/flutter_test.dart';

import 'package:turbo_widgets_example/core/services/mock_content_service.dart';
import 'package:turbo_widgets_example/showcase/feature/layout_and_motion/views/t_collapsible_section_showcase/t_collapsible_section_showcase_view_model.dart';

void main() {
  late MockContentService mockContentService;
  late TCollapsibleSectionShowcaseViewModel sut;

  setUp(() {
    mockContentService = MockContentService();
    sut = TCollapsibleSectionShowcaseViewModel(
      mockContentService: mockContentService,
    );
  });

  group('GIVEN a freshly created TCollapsibleSectionShowcaseViewModel', () {
    test('THEN isExpanded defaults to true', () {
      expect(sut.isExpanded.value, isTrue);
    });

    test('THEN title defaults to the placeholder before initialise', () {
      expect(sut.title.value, 'Collapsible Section');
    });
  });

  group('GIVEN the view model is initialised', () {
    test('THEN title is sourced from MockContentService', () async {
      await sut.initialise();
      expect(sut.title.value, mockContentService.categories.first.title);
    });
  });

  group('GIVEN toggleExpanded is called', () {
    test('THEN isExpanded flips from true to false', () {
      sut.toggleExpanded();
      expect(sut.isExpanded.value, isFalse);
    });

    test('THEN calling again flips back to true', () {
      sut.toggleExpanded();
      sut.toggleExpanded();
      expect(sut.isExpanded.value, isTrue);
    });

    test('THEN isExpanded notifies', () {
      var notified = false;
      sut.isExpanded.addListener(() => notified = true);
      sut.toggleExpanded();
      expect(notified, isTrue);
    });
  });

  group('GIVEN updateTitle is called', () {
    test('THEN title reflects the new value', () {
      sut.updateTitle('New Section Title');
      expect(sut.title.value, 'New Section Title');
    });

    test('THEN title notifies', () {
      var notified = false;
      sut.title.addListener(() => notified = true);
      sut.updateTitle('Changed');
      expect(notified, isTrue);
    });
  });
}
