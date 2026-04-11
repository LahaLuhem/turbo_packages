import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import 'package:turbo_widgets_example/core/services/mock_content_service.dart';
import 'package:turbo_widgets_example/showcase/feature/detail_and_forms/views/t_interactive_form_showcase/t_interactive_form_showcase_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockContentService mockContentService;
  late TInteractiveFormShowcaseViewModel sut;

  setUp(() async {
    mockContentService = MockContentService();
    sut = TInteractiveFormShowcaseViewModel(
      mockContentService: mockContentService,
    );
    await sut.initialise();
  });

  group('GIVEN a freshly initialised TInteractiveFormShowcaseViewModel', () {
    test('THEN the controller has exactly three step configs', () {
      expect(sut.controller.stepConfigs.length, 3);
    });

    test('THEN the first step is a text input', () {
      expect(
        sut.controller.stepConfigs[0],
        isA<TTextInputStepConfig>(),
      );
    });

    test('THEN the second step is a card selection', () {
      expect(
        sut.controller.stepConfigs[1],
        isA<TCardSelectionStepConfig>(),
      );
    });

    test('THEN the third step is a calendar', () {
      expect(
        sut.controller.stepConfigs[2],
        isA<TCalendarStepConfig>(),
      );
    });

    test('THEN selectedPlan defaults to null', () {
      expect(sut.selectedPlan.value, isNull);
    });

    test('THEN selectedDate defaults to null', () {
      expect(sut.selectedDate.value, isNull);
    });
  });

  group('GIVEN the card selection step cards are tapped', () {
    test('THEN selectedPlan reflects the tapped plan title', () {
      final cards =
          (sut.controller.stepConfigs[1] as TCardSelectionStepConfig).cards;
      cards.first.onTap();
      expect(sut.selectedPlan.value, cards.first.title);
    });

    test('THEN the tapped card reports isSelected as true', () {
      final cards =
          (sut.controller.stepConfigs[1] as TCardSelectionStepConfig).cards;
      cards.first.onTap();
      expect(cards.first.isSelected(), isTrue);
    });

    test('THEN other cards report isSelected as false', () {
      final cards =
          (sut.controller.stepConfigs[1] as TCardSelectionStepConfig).cards;
      cards.first.onTap();
      for (int i = 1; i < cards.length; i++) {
        expect(cards[i].isSelected(), isFalse);
      }
    });

    test('THEN selecting a different plan updates selectedPlan', () {
      final cards =
          (sut.controller.stepConfigs[1] as TCardSelectionStepConfig).cards;
      cards.first.onTap();
      cards.last.onTap();
      expect(sut.selectedPlan.value, cards.last.title);
    });

    test('THEN selectedPlan notifies listeners', () {
      var notified = false;
      sut.selectedPlan.addListener(() => notified = true);
      final cards =
          (sut.controller.stepConfigs[1] as TCardSelectionStepConfig).cards;
      cards.first.onTap();
      expect(notified, isTrue);
    });
  });

  group('GIVEN the calendar step date is selected', () {
    test('THEN selectedDate reflects the chosen date', () {
      final calendarConfig =
          sut.controller.stepConfigs[2] as TCalendarStepConfig;
      final date = DateTime(2026, 6, 15);
      calendarConfig.onDateSelected(date);
      expect(sut.selectedDate.value, date);
    });

    test('THEN selectedDate notifies listeners', () {
      var notified = false;
      sut.selectedDate.addListener(() => notified = true);
      final calendarConfig =
          sut.controller.stepConfigs[2] as TCalendarStepConfig;
      calendarConfig.onDateSelected(DateTime(2026, 6, 15));
      expect(notified, isTrue);
    });
  });

  group('GIVEN the text input step validation', () {
    test('THEN empty name is invalid', () {
      final textConfig =
          sut.controller.stepConfigs[0] as TTextInputStepConfig;
      textConfig.textEditingController.text = '';
      expect(textConfig.isValid(), isFalse);
    });

    test('THEN whitespace-only name is invalid', () {
      final textConfig =
          sut.controller.stepConfigs[0] as TTextInputStepConfig;
      textConfig.textEditingController.text = '   ';
      expect(textConfig.isValid(), isFalse);
    });

    test('THEN non-empty name is valid', () {
      final textConfig =
          sut.controller.stepConfigs[0] as TTextInputStepConfig;
      textConfig.textEditingController.text = 'Alice';
      expect(textConfig.isValid(), isTrue);
    });
  });

  group('GIVEN the card selection step validation', () {
    test('THEN no selection is invalid', () {
      expect(sut.controller.stepConfigs[1].isValid(), isFalse);
    });

    test('THEN after selecting a plan it is valid', () {
      final cards =
          (sut.controller.stepConfigs[1] as TCardSelectionStepConfig).cards;
      cards.first.onTap();
      expect(sut.controller.stepConfigs[1].isValid(), isTrue);
    });
  });

  group('GIVEN the calendar step validation', () {
    test('THEN no date is invalid', () {
      expect(sut.controller.stepConfigs[2].isValid(), isFalse);
    });

    test('THEN after selecting a date it is valid', () {
      final calendarConfig =
          sut.controller.stepConfigs[2] as TCalendarStepConfig;
      calendarConfig.onDateSelected(DateTime(2026, 6, 15));
      expect(sut.controller.stepConfigs[2].isValid(), isTrue);
    });
  });

}
