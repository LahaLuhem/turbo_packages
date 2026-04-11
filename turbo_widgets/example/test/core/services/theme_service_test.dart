import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets_example/core/services/theme_service.dart';

void main() {
  late ThemeService sut;

  setUp(() {
    sut = ThemeService();
  });

  group('GIVEN a ThemeService', () {
    group('WHEN freshly created', () {
      test('THEN brightness defaults to light', () {
        expect(sut.brightness.value, Brightness.light);
      });
    });

    group('WHEN toggleBrightness is called once', () {
      test('THEN brightness switches to dark', () {
        sut.toggleBrightness();
        expect(sut.brightness.value, Brightness.dark);
      });
    });

    group('WHEN toggleBrightness is called twice', () {
      test('THEN brightness returns to light', () {
        sut.toggleBrightness();
        sut.toggleBrightness();
        expect(sut.brightness.value, Brightness.light);
      });
    });

    group('WHEN toggled', () {
      test('THEN brightness is a listenable that notifies', () {
        var notified = false;
        sut.brightness.addListener(() => notified = true);
        sut.toggleBrightness();
        expect(notified, isTrue);
      });
    });
  });
}
