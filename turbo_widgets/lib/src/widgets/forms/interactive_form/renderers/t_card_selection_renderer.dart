import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../controllers/t_interactive_form_controller.dart';
import '../models/t_interactive_form_step_config.dart';

class TCardSelectionRenderer extends StatelessWidget {
  const TCardSelectionRenderer({
    super.key,
    required this.config,
    required this.controller,
  });

  final TCardSelectionStepConfig config;
  final TInteractiveFormController controller;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final card in config.cards)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: GestureDetector(
              onTap: () {
                card.onTap();
                controller.onInteraction();
                controller.nextStep();
              },
              child: ShadCard(
                width: double.infinity,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (card.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(card.icon, size: 20),
                      ),
                    if (card.svgPath != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SvgPicture.asset(
                          card.svgPath!,
                          width: 20,
                          height: 20,
                        ),
                      ),
                    Text(card.title),
                  ],
                ),
                border: card.isSelected()
                    ? ShadBorder.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
            ),
          ),
      ],
    ),
  );
}
