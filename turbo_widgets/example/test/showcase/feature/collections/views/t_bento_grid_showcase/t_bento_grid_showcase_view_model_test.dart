import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import 'package:turbo_widgets_example/showcase/feature/collections/views/t_bento_grid_showcase/t_bento_grid_showcase_view_model.dart';

void main() {
  late TBentoGridShowcaseViewModel sut;

  setUp(() {
    sut = TBentoGridShowcaseViewModel();
  });

  group('GIVEN a freshly created TBentoGridShowcaseViewModel', () {
    test('THEN sizes defaults to 5 items', () {
      expect(sut.sizes.value.length, 5);
    });

    test('THEN animation defaults to fade', () {
      expect(sut.animation.value, TBentoGridAnimation.fade);
    });

    test('THEN spacing defaults to 8.0', () {
      expect(sut.spacing.value, 8.0);
    });

    test('THEN showAddRemoveControls defaults to true', () {
      expect(sut.showAddRemoveControls.value, isTrue);
    });
  });

  group('GIVEN addItem is called', () {
    test('THEN sizes list grows by one', () {
      final countBefore = sut.sizes.value.length;
      sut.addItem(3.0);
      expect(sut.sizes.value.length, countBefore + 1);
    });

    test('THEN the new item has the given size', () {
      sut.addItem(3.0);
      expect(sut.sizes.value.last, 3.0);
    });

    test('THEN sizes notifies', () {
      var notified = false;
      sut.sizes.addListener(() => notified = true);
      sut.addItem(1.0);
      expect(notified, isTrue);
    });
  });

  group('GIVEN removeLastItem is called', () {
    test('THEN sizes list shrinks by one', () {
      final countBefore = sut.sizes.value.length;
      sut.removeLastItem();
      expect(sut.sizes.value.length, countBefore - 1);
    });

    test('THEN it is a no-op when only one item remains', () {
      // Remove until 1 item remains.
      while (sut.sizes.value.length > 1) {
        sut.removeLastItem();
      }
      expect(sut.sizes.value.length, 1);

      sut.removeLastItem();
      expect(sut.sizes.value.length, 1);
    });

    test('THEN sizes notifies', () {
      var notified = false;
      sut.sizes.addListener(() => notified = true);
      sut.removeLastItem();
      expect(notified, isTrue);
    });
  });

  group('GIVEN updateItemSize is called', () {
    test('THEN the item at the given index is updated', () {
      sut.updateItemSize(0, 10.0);
      expect(sut.sizes.value[0], 10.0);
    });

    test('THEN other items are unaffected', () {
      final originalSecond = sut.sizes.value[1];
      sut.updateItemSize(0, 10.0);
      expect(sut.sizes.value[1], originalSecond);
    });

    test('THEN out-of-bounds index is a no-op', () {
      final before = List<double>.from(sut.sizes.value);
      sut.updateItemSize(99, 10.0);
      expect(sut.sizes.value, before);
    });

    test('THEN negative index is a no-op', () {
      final before = List<double>.from(sut.sizes.value);
      sut.updateItemSize(-1, 10.0);
      expect(sut.sizes.value, before);
    });
  });

  group('GIVEN animation is updated', () {
    test('THEN animation reflects the new value', () {
      sut.updateAnimation(TBentoGridAnimation.slide);
      expect(sut.animation.value, TBentoGridAnimation.slide);

      sut.updateAnimation(TBentoGridAnimation.scale);
      expect(sut.animation.value, TBentoGridAnimation.scale);

      sut.updateAnimation(TBentoGridAnimation.none);
      expect(sut.animation.value, TBentoGridAnimation.none);
    });
  });

  group('GIVEN spacing is updated', () {
    test('THEN spacing reflects the new value', () {
      sut.updateSpacing(16.0);
      expect(sut.spacing.value, 16.0);
    });
  });

  group('GIVEN toggleShowAddRemoveControls is called', () {
    test('THEN showAddRemoveControls flips from true to false', () {
      sut.toggleShowAddRemoveControls();
      expect(sut.showAddRemoveControls.value, isFalse);
    });

    test('THEN calling again flips back to true', () {
      sut.toggleShowAddRemoveControls();
      sut.toggleShowAddRemoveControls();
      expect(sut.showAddRemoveControls.value, isTrue);
    });
  });

  group('GIVEN multiple add and remove operations', () {
    test('THEN sizes list reflects the accumulated changes', () {
      sut.addItem(5.0);
      sut.addItem(3.0);
      expect(sut.sizes.value.length, 7);

      sut.removeLastItem();
      expect(sut.sizes.value.length, 6);
      expect(sut.sizes.value.last, 5.0);
    });
  });
}
