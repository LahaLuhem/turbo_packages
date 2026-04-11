import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import 'package:turbo_widgets_example/core/services/mock_content_service.dart';

/// Drives the product detail page for [TInteractiveForm].
///
/// Owns a [TInteractiveFormController] with three steps:
/// 1. Text input (name)
/// 2. Card selection (plan — from [MockContentService.plans])
/// 3. Calendar (date picking)
///
/// The controller is constructed during [initialise] and disposed
/// during [dispose].
class TInteractiveFormShowcaseViewModel extends TBaseViewModel<void> {
  TInteractiveFormShowcaseViewModel({
    required MockContentService mockContentService,
  }) : _mockContentService = mockContentService;

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final MockContentService _mockContentService;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    _controller = TInteractiveFormController(
      stepConfigs: [
        TTextInputStepConfig(
          label: 'Your name',
          textEditingController: _nameController,
          focusNode: _nameFocusNode,
          isValid: () => _nameController.text.trim().isNotEmpty,
        ),
        TCardSelectionStepConfig(
          label: 'Choose a plan',
          cards: _buildPlanCards(),
          isValid: () => _selectedPlan.value != null,
        ),
        TCalendarStepConfig(
          label: 'Pick a date',
          onDateSelected: _onDateSelected,
          isValid: () => _selectedDate.value != null,
        ),
      ],
    );
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _selectedPlan.dispose();
    _selectedDate.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  late final TInteractiveFormController _controller;

  final TextEditingController _nameController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();

  final TNotifier<String?> _selectedPlan = TNotifier<String?>(null);

  final TNotifier<DateTime?> _selectedDate = TNotifier<DateTime?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The owned interactive form controller.
  TInteractiveFormController get controller => _controller;

  /// The currently selected plan title, or `null`.
  ValueListenable<String?> get selectedPlan => _selectedPlan;

  /// The currently selected date, or `null`.
  ValueListenable<DateTime?> get selectedDate => _selectedDate;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  List<TCardOption> _buildPlanCards() {
    return _mockContentService.plans
        .map(
          (template) => TCardOption(
            title: template.title,
            icon: template.icon,
            svgPath: template.svgPath,
            onTap: () => _selectedPlan.value = template.title,
            isSelected: () => _selectedPlan.value == template.title,
          ),
        )
        .toList();
  }

  void _onDateSelected(DateTime date) {
    _selectedDate.value = date;
  }
}
