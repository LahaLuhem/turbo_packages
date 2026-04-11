import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/t_interactive_form_step_config.dart';

// <SUBJECT_2026_0130_23_51>
class TInteractiveFormController {
  TInteractiveFormController({
    required this.stepConfigs,
    int startingStepIndex = 0,
  }) : _currentStepIndex = ValueNotifier<int>(startingStepIndex),
       _backgroundVisible = ValueNotifier<bool>(true),
       pageController = PageController(initialPage: startingStepIndex) {
    pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_backgroundVisible.value) return;
    final page = pageController.page;
    if (page == null) return;
    if ((page - _currentStepIndex.value).abs() > 0.01) {
      onInteraction();
    }
  }

  final List<TInteractiveFormStepConfig> stepConfigs;
  final PageController pageController;
  final ValueNotifier<int> _currentStepIndex;
  final ValueNotifier<bool> _backgroundVisible;

  ValueListenable<int> get currentStepIndex => _currentStepIndex;
  ValueListenable<bool> get backgroundVisible => _backgroundVisible;

  void goToStep(int index) {
    if (index < 0 || index >= stepConfigs.length) return;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _currentStepIndex.value = index;
  }

  void nextStep() {
    if (_currentStepIndex.value < stepConfigs.length - 1) {
      goToStep(_currentStepIndex.value + 1);
    }
  }

  void previousStep() {
    if (_currentStepIndex.value > 0) {
      goToStep(_currentStepIndex.value - 1);
    }
  }

  void onInteraction() {
    if (_backgroundVisible.value) {
      _backgroundVisible.value = false;
    }
  }

  bool validate() {
    for (int i = 0; i < stepConfigs.length; i++) {
      final config = stepConfigs[i];
      if (!config.isValid()) {
        goToStep(i);
        if (config is TTextInputStepConfig) {
          config.focusNode.requestFocus();
          config.textEditingController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: config.textEditingController.text.length,
          );
        }
        return false;
      }
    }
    return true;
  }

  void onPageChanged(int index) {
    _currentStepIndex.value = index;
    final config = stepConfigs[index];
    if (config is TTextInputStepConfig) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        config.focusNode.requestFocus();
      });
    }
  }

  void dispose() {
    pageController.removeListener(_onScroll);
    pageController.dispose();
    _currentStepIndex.dispose();
    _backgroundVisible.dispose();
  }
}

// </SUBJECT_2026_0130_23_51>

// #FEEDBACK #TODO regarding `{{ SUBJECT_2026_0130_23_51 }}` | add dart docs
