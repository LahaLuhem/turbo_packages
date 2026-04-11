import 'package:flutter/foundation.dart';
import 'package:turbo_forms/turbo_forms.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Display mode for the [TFormSection] showcase.
enum FormSectionMode {
  /// Renders the section using a [TFormConfig] with auto-generated fields.
  formConfig,

  /// Renders the section using explicit child widgets.
  children,
}

/// Enum identifying each field in the [ShowcaseFormConfig].
enum ShowcaseFormField {
  name,
  role,
  isActive,
}

/// A sample [TFormConfig] for the form section showcase.
///
/// Contains three fields: a text input (name), a select (role), and a
/// checkbox (isActive).
class ShowcaseFormConfig extends TFormConfig {
  TFormFieldConfig<String> get name =>
      formFieldConfig(ShowcaseFormField.name);
  TFormFieldConfig<String> get role =>
      formFieldConfig(ShowcaseFormField.role);
  TFormFieldConfig<bool> get isActive =>
      formFieldConfig(ShowcaseFormField.isActive);

  @override
  late final Map<Enum, TFormFieldConfig> formFieldConfigs = {
    ShowcaseFormField.name: TFormFieldConfig<String>(
      id: ShowcaseFormField.name,
      fieldType: TFieldType.textInput,
      initialValue: 'Brian Manuputty',
    ),
    ShowcaseFormField.role: TFormFieldConfig<String>(
      id: ShowcaseFormField.role,
      fieldType: TFieldType.select,
      items: const ['Developer', 'Designer', 'Manager', 'Analyst'],
      initialValue: 'Developer',
    ),
    ShowcaseFormField.isActive: TFormFieldConfig<bool>(
      id: ShowcaseFormField.isActive,
      fieldType: TFieldType.checkbox,
      initialValue: true,
    ),
  };
}

/// Drives the product detail page for [TFormSection].
///
/// Exposes a mode cell toggling between formConfig-driven and
/// children-driven display, plus the form config itself.
class TFormSectionShowcaseViewModel extends TBaseViewModel<void> {
  TFormSectionShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _mode.dispose();
    _formConfig.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<FormSectionMode> _mode =
      TNotifier<FormSectionMode>(FormSectionMode.formConfig);

  final ShowcaseFormConfig _formConfig = ShowcaseFormConfig();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The active display mode.
  ValueListenable<FormSectionMode> get mode => _mode;

  /// The form configuration used in [FormSectionMode.formConfig] mode.
  ShowcaseFormConfig get formConfig => _formConfig;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateMode(FormSectionMode mode) {
    _mode.value = mode;
  }
}
