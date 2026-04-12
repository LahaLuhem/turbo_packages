import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'controllers/t_interactive_form_controller.dart';
import 'models/t_interactive_form_step_config.dart';
import 'renderers/t_calendar_renderer.dart';
import 'renderers/t_card_selection_renderer.dart';
import 'renderers/t_text_input_renderer.dart';

// <SUBJECT_2026_0130_23_04>
typedef TInteractiveFormWidgetBuilder =
    Widget Function(
      BuildContext context,
      TInteractiveFormController controller,
    );
// </SUBJECT_2026_0130_23_04>

// #FEEDBACK #TODO regarding `{{ SUBJECT_2026_0130_23_04 }}` | put this inside its own file

class TInteractiveForm extends StatelessWidget {
  const TInteractiveForm({
    super.key,
    required this.controller,
    this.background,
    this.showTopBar = true,
    this.bottomBarWrapper,
    this.pageWrapper,
    this.leftButtonBuilder,
    this.rightButtonBuilder,
    this.saveButtonBuilder,
    this.topCloseBuilder,
    this.topLeftBuilder,
    this.topRightBuilder,
    this.labelBuilder,
  });

  final TInteractiveFormController controller;
  final Widget? background;
  final bool showTopBar;
  final Widget Function(Widget bottomBar)? bottomBarWrapper;
  final Widget Function(int index, Widget page)? pageWrapper;
  final TInteractiveFormWidgetBuilder? leftButtonBuilder;
  final TInteractiveFormWidgetBuilder? rightButtonBuilder;
  final TInteractiveFormWidgetBuilder? saveButtonBuilder;
  final TInteractiveFormWidgetBuilder? topCloseBuilder;
  final TInteractiveFormWidgetBuilder? topLeftBuilder;
  final TInteractiveFormWidgetBuilder? topRightBuilder;
  final TInteractiveFormWidgetBuilder? labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showTopBar)
          _TopBar(
            controller: controller,
            topCloseBuilder: topCloseBuilder,
            topLeftBuilder: topLeftBuilder,
            topRightBuilder: topRightBuilder,
            labelBuilder: labelBuilder,
          ),
        Expanded(
          child: Stack(
            children: [
              if (background != null)
                Align(
                  alignment: const Alignment(0, -0.75),
                  child: IgnorePointer(
                    child: _BackgroundLayer(
                      controller: controller,
                      background: background!,
                    ),
                  ),
                ),
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.stepConfigs.length,
                itemBuilder: (context, index) {
                  final page = _StepRenderer(
                    config: controller.stepConfigs[index],
                    controller: controller,
                  );
                  return pageWrapper?.call(index, page) ?? page;
                },
              ),
            ],
          ),
        ),
        Builder(
          builder: (context) {
            final bottomBar = _BottomBar(
              controller: controller,
              leftButtonBuilder: leftButtonBuilder,
              saveButtonBuilder: saveButtonBuilder,
              rightButtonBuilder: rightButtonBuilder,
            );
            return bottomBarWrapper?.call(bottomBar) ?? bottomBar;
          },
        ),
      ],
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({
    required this.controller,
    required this.background,
  });

  final TInteractiveFormController controller;
  final Widget background;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.backgroundVisible,
      builder: (context, visible, child) {
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
      child: background,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.controller,
    this.topCloseBuilder,
    this.topLeftBuilder,
    this.topRightBuilder,
    this.labelBuilder,
  });

  final TInteractiveFormController controller;
  final TInteractiveFormWidgetBuilder? topCloseBuilder;
  final TInteractiveFormWidgetBuilder? topLeftBuilder;
  final TInteractiveFormWidgetBuilder? topRightBuilder;
  final TInteractiveFormWidgetBuilder? labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          topCloseBuilder?.call(context, controller) ??
              ShadIconButton.ghost(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
          if (topLeftBuilder != null) topLeftBuilder!(context, controller),
          const Spacer(),
          labelBuilder?.call(context, controller) ??
              _DefaultLabel(controller: controller),
          const Spacer(),
          if (topRightBuilder != null)
            topRightBuilder!(context, controller)
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _DefaultLabel extends StatelessWidget {
  const _DefaultLabel({required this.controller});

  final TInteractiveFormController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.currentStepIndex,
      builder: (context, index, _) {
        return ShadCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            controller.stepConfigs[index].label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.controller,
    this.leftButtonBuilder,
    this.saveButtonBuilder,
    this.rightButtonBuilder,
  });

  final TInteractiveFormController controller;
  final TInteractiveFormWidgetBuilder? leftButtonBuilder;
  final TInteractiveFormWidgetBuilder? saveButtonBuilder;
  final TInteractiveFormWidgetBuilder? rightButtonBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ValueListenableBuilder<int>(
        valueListenable: controller.currentStepIndex,
        builder: (context, index, _) {
          final isFirst = index == 0;
          final isLast = index == controller.stepConfigs.length - 1;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leftButtonBuilder?.call(context, controller) ??
                  ShadIconButton.outline(
                    icon: const Icon(LucideIcons.chevronLeft),
                    enabled: !isFirst,
                    onPressed: isFirst ? null : controller.previousStep,
                  ),
              const SizedBox(width: 8),
              saveButtonBuilder?.call(context, controller) ??
                  ShadButton(
                    onPressed: () {},
                    child: const Text('Save'),
                  ),
              const SizedBox(width: 8),
              rightButtonBuilder?.call(context, controller) ??
                  ShadIconButton.outline(
                    icon: const Icon(LucideIcons.chevronRight),
                    enabled: !isLast,
                    onPressed: isLast ? null : controller.nextStep,
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _StepRenderer extends StatelessWidget {
  const _StepRenderer({
    required this.config,
    required this.controller,
  });

  final TInteractiveFormStepConfig config;
  final TInteractiveFormController controller;

  @override
  Widget build(BuildContext context) {
    final stepConfig = config;
    return switch (stepConfig) {
      TTextInputStepConfig() => TTextInputRenderer(
        config: stepConfig,
        controller: controller,
      ),
      TCardSelectionStepConfig() => TCardSelectionRenderer(
        config: stepConfig,
        controller: controller,
      ),
      TCalendarStepConfig() => TCalendarRenderer(
        config: stepConfig,
        controller: controller,
      ),
    };
  }
}
