import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../controllers/t_interactive_form_controller.dart';
import '../models/t_interactive_form_step_config.dart';

class TCalendarRenderer extends StatelessWidget {
  const TCalendarRenderer({
    super.key,
    required this.config,
    required this.controller,
  });

  final TCalendarStepConfig config;
  final TInteractiveFormController controller;

  @override
  Widget build(BuildContext context) => ShadCalendar(
    selected: config.selected,
    fromMonth: config.minDate,
    toMonth: config.maxDate,
    onChanged: (date) {
      if (date != null) {
        config.onDateSelected(date);
        controller.onInteraction();
        controller.nextStep();
      }
    },
  );
}
