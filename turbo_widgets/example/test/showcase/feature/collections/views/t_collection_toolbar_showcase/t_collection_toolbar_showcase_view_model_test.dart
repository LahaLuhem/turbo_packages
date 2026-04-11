import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import 'package:turbo_widgets_example/showcase/feature/collections/views/t_collection_toolbar_showcase/t_collection_toolbar_showcase_view_model.dart';

void main() {
  late TCollectionToolbarShowcaseViewModel sut;

  setUp(() {
    sut = TCollectionToolbarShowcaseViewModel();
  });

  group('GIVEN a freshly created TCollectionToolbarShowcaseViewModel', () {
    test('THEN searchQuery defaults to empty', () {
      expect(sut.searchQuery.value, isEmpty);
    });

    test('THEN sortValue defaults to null', () {
      expect(sut.sortValue.value, isNull);
    });

    test('THEN filterValue defaults to null', () {
      expect(sut.filterValue.value, isNull);
    });

    test('THEN layout defaults to bento', () {
      expect(sut.layout.value, TCollectionSectionLayout.bento);
    });

    test('THEN lastCallbackFired defaults to null', () {
      expect(sut.lastCallbackFired.value, isNull);
    });
  });

  group('GIVEN updateSearchQuery is called', () {
    setUp(() {
      sut.updateSearchQuery('test');
    });

    test('THEN searchQuery reflects the new value', () {
      expect(sut.searchQuery.value, 'test');
    });

    test('THEN lastCallbackFired is updated', () {
      expect(sut.lastCallbackFired.value, isNotNull);
    });
  });

  group('GIVEN updateSortValue is called', () {
    setUp(() {
      sut.updateSortValue(TCollectionToolbarShowcaseViewModel.sortByName);
    });

    test('THEN sortValue reflects the new value', () {
      expect(sut.sortValue.value, TCollectionToolbarShowcaseViewModel.sortByName);
    });

    test('THEN lastCallbackFired is updated', () {
      expect(sut.lastCallbackFired.value, isNotNull);
    });
  });

  group('GIVEN updateFilterValue is called', () {
    setUp(() {
      sut.updateFilterValue(TCollectionToolbarShowcaseViewModel.filterActive);
    });

    test('THEN filterValue reflects the new value', () {
      expect(
        sut.filterValue.value,
        TCollectionToolbarShowcaseViewModel.filterActive,
      );
    });

    test('THEN lastCallbackFired is updated', () {
      expect(sut.lastCallbackFired.value, isNotNull);
    });
  });

  group('GIVEN updateLayout is called', () {
    test('THEN layout reflects the new value', () {
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(sut.layout.value, TCollectionSectionLayout.list);

      sut.updateLayout(TCollectionSectionLayout.grid);
      expect(sut.layout.value, TCollectionSectionLayout.grid);
    });

    test('THEN lastCallbackFired is updated', () {
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(sut.lastCallbackFired.value, isNotNull);
    });
  });

  group('GIVEN multiple cells are mutated in sequence', () {
    test('THEN lastCallbackFired tracks the most recent change', () {
      sut.updateSearchQuery('hello');
      expect(sut.lastCallbackFired.value, contains('Search'));

      sut.updateSortValue(TCollectionToolbarShowcaseViewModel.sortByDate);
      expect(sut.lastCallbackFired.value, contains('Sort'));

      sut.updateFilterValue(TCollectionToolbarShowcaseViewModel.filterArchived);
      expect(sut.lastCallbackFired.value, contains('Filter'));

      sut.updateLayout(TCollectionSectionLayout.grid);
      expect(sut.lastCallbackFired.value, contains('Layout'));
    });
  });

  group('GIVEN reactive notifications', () {
    test('WHEN updateSearchQuery is called THEN searchQuery notifies', () {
      var notified = false;
      sut.searchQuery.addListener(() => notified = true);
      sut.updateSearchQuery('query');
      expect(notified, isTrue);
    });

    test('WHEN updateSortValue is called THEN sortValue notifies', () {
      var notified = false;
      sut.sortValue.addListener(() => notified = true);
      sut.updateSortValue(TCollectionToolbarShowcaseViewModel.sortByName);
      expect(notified, isTrue);
    });

    test('WHEN updateFilterValue is called THEN filterValue notifies', () {
      var notified = false;
      sut.filterValue.addListener(() => notified = true);
      sut.updateFilterValue(TCollectionToolbarShowcaseViewModel.filterActive);
      expect(notified, isTrue);
    });

    test('WHEN updateLayout is called THEN layout notifies', () {
      var notified = false;
      sut.layout.addListener(() => notified = true);
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(notified, isTrue);
    });

    test('WHEN any mutator is called THEN lastCallbackFired notifies', () {
      var notified = false;
      sut.lastCallbackFired.addListener(() => notified = true);
      sut.updateSearchQuery('x');
      expect(notified, isTrue);
    });
  });
}
