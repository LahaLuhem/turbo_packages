import 'package:flutter_test/flutter_test.dart';

import 'package:turbo_widgets_example/showcase/feature/detail_and_forms/views/t_detail_header_showcase/t_detail_header_showcase_view_model.dart';

void main() {
  late TDetailHeaderShowcaseViewModel sut;

  setUp(() {
    sut = TDetailHeaderShowcaseViewModel();
  });

  group('GIVEN a freshly created TDetailHeaderShowcaseViewModel', () {
    test('THEN title defaults to Widget Detail', () {
      expect(sut.title.value, 'Widget Detail');
    });

    test('THEN subtitle defaults to a description string', () {
      expect(sut.subtitle.value, isNotEmpty);
    });

    test('THEN showSave defaults to true', () {
      expect(sut.showSave.value, isTrue);
    });

    test('THEN lastSaveFired defaults to null', () {
      expect(sut.lastSaveFired.value, isNull);
    });
  });

  group('GIVEN updateTitle is called', () {
    test('THEN title reflects the new value', () {
      sut.updateTitle('New Title');
      expect(sut.title.value, 'New Title');
    });

    test('THEN title notifies listeners', () {
      var notified = false;
      sut.title.addListener(() => notified = true);
      sut.updateTitle('Changed');
      expect(notified, isTrue);
    });
  });

  group('GIVEN updateSubtitle is called', () {
    test('THEN subtitle reflects the new value', () {
      sut.updateSubtitle('New Subtitle');
      expect(sut.subtitle.value, 'New Subtitle');
    });
  });

  group('GIVEN toggleShowSave is called', () {
    test('THEN showSave flips from true to false', () {
      sut.toggleShowSave();
      expect(sut.showSave.value, isFalse);
    });

    test('THEN calling again flips back to true', () {
      sut.toggleShowSave();
      sut.toggleShowSave();
      expect(sut.showSave.value, isTrue);
    });
  });

  group('GIVEN onSave is called', () {
    test('THEN lastSaveFired is updated to a non-null value', () {
      sut.onSave();
      expect(sut.lastSaveFired.value, isNotNull);
    });

    test('THEN lastSaveFired contains a timestamp', () {
      sut.onSave();
      expect(sut.lastSaveFired.value, contains('Save tapped at'));
    });

    test('THEN lastSaveFired notifies listeners', () {
      var notified = false;
      sut.lastSaveFired.addListener(() => notified = true);
      sut.onSave();
      expect(notified, isTrue);
    });

    test('THEN calling again updates to a new value', () {
      sut.onSave();
      final first = sut.lastSaveFired.value;
      sut.onSave();
      expect(sut.lastSaveFired.value, isNot(equals(first)));
    });
  });
}
