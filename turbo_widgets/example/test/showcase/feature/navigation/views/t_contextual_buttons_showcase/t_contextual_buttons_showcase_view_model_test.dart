import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import 'package:turbo_widgets_example/showcase/feature/navigation/views/t_contextual_buttons_showcase/t_contextual_buttons_showcase_view_model.dart';

void main() {
  late TContextualButtonsShowcaseViewModel sut;

  setUp(() {
    sut = TContextualButtonsShowcaseViewModel();
  });

  group('GIVEN a freshly created TContextualButtonsShowcaseViewModel', () {
    test('THEN showTop defaults to true', () {
      expect(sut.showTop.value, isTrue);
    });

    test('THEN showBottom defaults to true', () {
      expect(sut.showBottom.value, isTrue);
    });

    test('THEN showLeft defaults to false', () {
      expect(sut.showLeft.value, isFalse);
    });

    test('THEN showRight defaults to false', () {
      expect(sut.showRight.value, isFalse);
    });

    test('THEN allowFilter defaults to all', () {
      expect(sut.allowFilter.value, TContextualAllowFilter.all);
    });

    test('THEN lastConfigChange defaults to null', () {
      expect(sut.lastConfigChange.value, isNull);
    });

    test('THEN hiddenPositions contains left and right', () {
      expect(sut.hiddenPositions, {
        TContextualPosition.left,
        TContextualPosition.right,
      });
    });
  });

  group('GIVEN toggleShowTop is called', () {
    setUp(() {
      sut.toggleShowTop();
    });

    test('THEN showTop flips to false', () {
      expect(sut.showTop.value, isFalse);
    });

    test('THEN hiddenPositions includes top', () {
      expect(sut.hiddenPositions, contains(TContextualPosition.top));
    });

    test('THEN lastConfigChange reflects the change', () {
      expect(sut.lastConfigChange.value, isNotNull);
    });
  });

  group('GIVEN toggleShowBottom is called', () {
    test('THEN showBottom flips to false', () {
      sut.toggleShowBottom();
      expect(sut.showBottom.value, isFalse);
    });
  });

  group('GIVEN toggleShowLeft is called', () {
    test('THEN showLeft flips to true', () {
      sut.toggleShowLeft();
      expect(sut.showLeft.value, isTrue);
    });

    test('THEN hiddenPositions no longer contains left', () {
      sut.toggleShowLeft();
      expect(
        sut.hiddenPositions.contains(TContextualPosition.left),
        isFalse,
      );
    });
  });

  group('GIVEN all positions are shown', () {
    setUp(() {
      sut.toggleShowLeft(); // false → true
      sut.toggleShowRight(); // false → true
    });

    test('THEN hiddenPositions is empty', () {
      expect(sut.hiddenPositions, isEmpty);
    });
  });

  group('GIVEN allowFilter is updated', () {
    test('THEN allowFilter reflects the new value', () {
      sut.updateAllowFilter(TContextualAllowFilter.top);
      expect(sut.allowFilter.value, TContextualAllowFilter.top);
    });

    test('THEN lastConfigChange reflects the change', () {
      sut.updateAllowFilter(TContextualAllowFilter.bottom);
      expect(sut.lastConfigChange.value, isNotNull);
    });
  });

  group('GIVEN reactive notifications', () {
    test('WHEN toggleShowTop is called THEN showTop notifies', () {
      var notified = false;
      sut.showTop.addListener(() => notified = true);
      sut.toggleShowTop();
      expect(notified, isTrue);
    });

    test('WHEN updateAllowFilter is called THEN allowFilter notifies', () {
      var notified = false;
      sut.allowFilter.addListener(() => notified = true);
      sut.updateAllowFilter(TContextualAllowFilter.left);
      expect(notified, isTrue);
    });

    test('WHEN any toggle is called THEN lastConfigChange notifies', () {
      var notified = false;
      sut.lastConfigChange.addListener(() => notified = true);
      sut.toggleShowRight();
      expect(notified, isTrue);
    });
  });
}
