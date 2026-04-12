import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../controllers/t_interactive_form_controller.dart';
import '../models/t_interactive_form_step_config.dart';

class TTextInputRenderer extends StatelessWidget {
  const TTextInputRenderer({
    super.key,
    required this.config,
    required this.controller,
  });

  final TTextInputStepConfig config;
  final TInteractiveFormController controller;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ShadInput(
              controller: config.textEditingController,
              focusNode: config.focusNode,
              maxLines: config.maxLines,
              textInputAction: config.textInputAction,
              textAlign: TextAlign.center,
              style:
                  config.styleBuilder?.call(context) ??
                  const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w800,
                  ),
              decoration: const ShadDecoration(
                border: ShadBorder(
                  top: ShadBorderSide(width: 0, color: Colors.transparent),
                  right: ShadBorderSide(width: 0, color: Colors.transparent),
                  bottom: ShadBorderSide(width: 0, color: Colors.transparent),
                  left: ShadBorderSide(width: 0, color: Colors.transparent),
                ),
                focusedBorder: ShadBorder(
                  top: ShadBorderSide(width: 0, color: Colors.transparent),
                  right: ShadBorderSide(width: 0, color: Colors.transparent),
                  bottom: ShadBorderSide(width: 0, color: Colors.transparent),
                  left: ShadBorderSide(width: 0, color: Colors.transparent),
                ),
                secondaryBorder: ShadBorder(
                  top: ShadBorderSide(width: 0, color: Colors.transparent),
                  right: ShadBorderSide(width: 0, color: Colors.transparent),
                  bottom: ShadBorderSide(width: 0, color: Colors.transparent),
                  left: ShadBorderSide(width: 0, color: Colors.transparent),
                ),
                secondaryFocusedBorder: ShadBorder(
                  top: ShadBorderSide(width: 0, color: Colors.transparent),
                  right: ShadBorderSide(width: 0, color: Colors.transparent),
                  bottom: ShadBorderSide(width: 0, color: Colors.transparent),
                  left: ShadBorderSide(width: 0, color: Colors.transparent),
                ),
              ),
              onChanged: (_) => controller.onInteraction(),
            ),
          ),
        ),
      ),
    ),
  );
}
