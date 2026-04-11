import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../enums/t_interactive_form_step_type.dart';
import 't_card_option.dart';

// <SUBJECT_2026_0130_24_01>
sealed class TInteractiveFormStepConfig {
  const TInteractiveFormStepConfig({
    required this.type,
    required this.label,
    required this.isValid,
  });

  final TInteractiveFormStepType type;
  final String label;
  final bool Function() isValid;
}

// </SUBJECT_2026_0130_24_01>

// #FEEDBACK #TODO regarding `{{ SUBJECT_2026_0130_24_01 }}` | make own file

class TTextInputStepConfig extends TInteractiveFormStepConfig {
  const TTextInputStepConfig({
    required super.label,
    required super.isValid,
    required this.textEditingController,
    required this.focusNode,
    this.maxLines,
    this.textInputAction,
    this.styleBuilder,
  }) : super(type: TInteractiveFormStepType.textInput);

  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final TextStyle Function(BuildContext context)? styleBuilder;
}

class TCardSelectionStepConfig extends TInteractiveFormStepConfig {
  const TCardSelectionStepConfig({
    required super.label,
    required super.isValid,
    required this.cards,
  }) : super(type: TInteractiveFormStepType.cardSelection);

  final List<TCardOption> cards;
}

class TCalendarStepConfig extends TInteractiveFormStepConfig {
  const TCalendarStepConfig({
    required super.label,
    required super.isValid,
    required this.onDateSelected,
    this.selected,
    this.minDate,
    this.maxDate,
  }) : super(type: TInteractiveFormStepType.calendar);

  final DateTime? selected;
  final DateTime? minDate;
  final DateTime? maxDate;
  final ValueChanged<DateTime> onDateSelected;
}
