import 'package:flutter_test/flutter_test.dart';

import 'package:turbo_widgets_example/showcase/feature/layout_and_motion/views/t_calculated_height_showcase/t_calculated_height_showcase_view_model.dart';

void main() {
  late TCalculatedHeightShowcaseViewModel sut;

  setUp(() {
    sut = TCalculatedHeightShowcaseViewModel();
  });

  group('GIVEN a freshly created TCalculatedHeightShowcaseViewModel', () {
    test('THEN count defaults to 5', () {
      expect(sut.count.value, 5);
    });

    test('THEN baseHeight defaults to 200.0', () {
      expect(sut.baseHeight.value, 200.0);
    });

    test('THEN multiplierThreshold defaults to 10.0', () {
      expect(sut.multiplierThreshold.value, 10.0);
    });

    test('THEN minHeight defaults to null', () {
      expect(sut.minHeight.value, isNull);
    });

    test('THEN maxHeight defaults to null', () {
      expect(sut.maxHeight.value, isNull);
    });
  });

  group('GIVEN addItem is called', () {
    test('THEN count increments by one', () {
      sut.addItem();
      expect(sut.count.value, 6);
    });

    test('THEN count notifies', () {
      var notified = false;
      sut.count.addListener(() => notified = true);
      sut.addItem();
      expect(notified, isTrue);
    });
  });

  group('GIVEN removeItem is called', () {
    test('THEN count decrements by one', () {
      sut.removeItem();
      expect(sut.count.value, 4);
    });

    test('THEN it is a no-op when count is already 0', () {
      sut.updateCount(0);
      sut.removeItem();
      expect(sut.count.value, 0);
    });

    test('THEN count notifies when decremented', () {
      var notified = false;
      sut.count.addListener(() => notified = true);
      sut.removeItem();
      expect(notified, isTrue);
    });

    test('THEN count does not notify when already at 0', () {
      sut.updateCount(0);
      var notified = false;
      sut.count.addListener(() => notified = true);
      sut.removeItem();
      expect(notified, isFalse);
    });
  });

  group('GIVEN updateCount is called', () {
    test('THEN count reflects the new value', () {
      sut.updateCount(42);
      expect(sut.count.value, 42);
    });

    test('THEN negative values are clamped to 0', () {
      sut.updateCount(-5);
      expect(sut.count.value, 0);
    });
  });

  group('GIVEN multiple add and remove operations', () {
    test('THEN count reflects accumulated changes', () {
      sut.addItem();
      sut.addItem();
      sut.addItem();
      expect(sut.count.value, 8);

      sut.removeItem();
      expect(sut.count.value, 7);
    });

    test('THEN removing all items stops at 0', () {
      sut.updateCount(2);
      sut.removeItem();
      sut.removeItem();
      sut.removeItem();
      expect(sut.count.value, 0);
    });
  });

  group('GIVEN parameter cells are updated', () {
    test('THEN baseHeight reflects the new value', () {
      sut.updateBaseHeight(300.0);
      expect(sut.baseHeight.value, 300.0);
    });

    test('THEN multiplierThreshold reflects the new value', () {
      sut.updateMultiplierThreshold(20.0);
      expect(sut.multiplierThreshold.value, 20.0);
    });

    test('THEN minHeight reflects the new value', () {
      sut.updateMinHeight(50.0);
      expect(sut.minHeight.value, 50.0);
    });

    test('THEN maxHeight reflects the new value', () {
      sut.updateMaxHeight(500.0);
      expect(sut.maxHeight.value, 500.0);
    });

    test('THEN minHeight can be set back to null', () {
      sut.updateMinHeight(50.0);
      sut.updateMinHeight(null);
      expect(sut.minHeight.value, isNull);
    });
  });
}
