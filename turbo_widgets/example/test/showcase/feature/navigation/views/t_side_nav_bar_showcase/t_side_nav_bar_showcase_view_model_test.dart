import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import 'package:turbo_widgets_example/showcase/feature/navigation/views/t_side_nav_bar_showcase/t_side_nav_bar_showcase_view_model.dart';

void main() {
  late TSideNavBarShowcaseViewModel sut;

  setUp(() {
    sut = TSideNavBarShowcaseViewModel();
  });

  group('GIVEN a freshly created TSideNavBarShowcaseViewModel', () {
    test('THEN layout defaults to auto', () {
      expect(sut.layout.value, TSideNavBarLayout.auto);
    });

    test('THEN isExpanded defaults to false', () {
      expect(sut.isExpanded.value, isFalse);
    });

    test('THEN selectedKey defaults to home', () {
      expect(sut.selectedKey.value, 'home');
    });

    test('THEN showDividers defaults to false', () {
      expect(sut.showDividers.value, isFalse);
    });

    test('THEN buttonAlignment defaults to start', () {
      expect(sut.buttonAlignment.value, TSideNavBarButtonAlignment.start);
    });

    test('THEN lastSelectedKey defaults to null', () {
      expect(sut.lastSelectedKey.value, isNull);
    });

    test('THEN sampleButtons contains 5 entries', () {
      expect(sut.sampleButtons.length, 5);
    });
  });

  group('GIVEN onSelect is called with a key', () {
    setUp(() {
      sut.onSelect('search');
    });

    test('THEN selectedKey updates to that key', () {
      expect(sut.selectedKey.value, 'search');
    });

    test('THEN lastSelectedKey updates to that key', () {
      expect(sut.lastSelectedKey.value, 'search');
    });
  });

  group('GIVEN toggleIsExpanded is called', () {
    test('THEN isExpanded flips from false to true', () {
      sut.toggleIsExpanded();
      expect(sut.isExpanded.value, isTrue);
    });

    test('THEN calling again flips back to false', () {
      sut.toggleIsExpanded();
      sut.toggleIsExpanded();
      expect(sut.isExpanded.value, isFalse);
    });
  });

  group('GIVEN layout is updated', () {
    test('THEN layout reflects the new value', () {
      sut.updateLayout(TSideNavBarLayout.vertical);
      expect(sut.layout.value, TSideNavBarLayout.vertical);

      sut.updateLayout(TSideNavBarLayout.horizontal);
      expect(sut.layout.value, TSideNavBarLayout.horizontal);
    });
  });

  group('GIVEN toggleShowDividers is called', () {
    test('THEN showDividers flips from false to true', () {
      sut.toggleShowDividers();
      expect(sut.showDividers.value, isTrue);
    });
  });

  group('GIVEN buttonAlignment is updated', () {
    test('THEN buttonAlignment reflects the new value', () {
      sut.updateButtonAlignment(TSideNavBarButtonAlignment.center);
      expect(sut.buttonAlignment.value, TSideNavBarButtonAlignment.center);

      sut.updateButtonAlignment(TSideNavBarButtonAlignment.spaceBetween);
      expect(
        sut.buttonAlignment.value,
        TSideNavBarButtonAlignment.spaceBetween,
      );
    });
  });

  group('GIVEN reactive notifications', () {
    test('WHEN onSelect is called THEN both selectedKey and lastSelectedKey notify', () {
      var selectedNotified = false;
      var lastNotified = false;
      sut.selectedKey.addListener(() => selectedNotified = true);
      sut.lastSelectedKey.addListener(() => lastNotified = true);
      sut.onSelect('profile');
      expect(selectedNotified, isTrue);
      expect(lastNotified, isTrue);
    });

    test('WHEN toggleIsExpanded is called THEN isExpanded notifies', () {
      var notified = false;
      sut.isExpanded.addListener(() => notified = true);
      sut.toggleIsExpanded();
      expect(notified, isTrue);
    });

    test('WHEN updateLayout is called THEN layout notifies', () {
      var notified = false;
      sut.layout.addListener(() => notified = true);
      sut.updateLayout(TSideNavBarLayout.vertical);
      expect(notified, isTrue);
    });
  });
}
