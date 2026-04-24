import 'package:flutter/material.dart';
import 'package:turbo_forms/src/config/t_form_field_config.dart';
import 'package:turbo_forms/src/constants/turbo_forms_defaults.dart';
import 'package:turbo_forms/src/typedefs/t_form_field_builder_def.dart';
import 'package:turbo_forms/src/widgets/t_error_label.dart';
import 'package:turbo_forms/src/widgets/t_form_field_builder.dart';

/// A reactive form field widget that rebuilds when its [TFormFieldConfig] changes.
///
/// Composes a label, description, error display, and custom field content
/// built via the [builder] callback.
class TFormField<T> extends StatelessWidget {
  const TFormField({
    super.key,
    required this.builder,
    required this.formFieldConfig,
    this.errorTextStyle,
    this.child,
    this.errorPadding,
    this.label,
    this.description,
    this.descriptionStyle,
    this.labelTrailing,
    this.horizontalPadding,
    this.disabledOpacity = TurboFormsDefaults.defaultDisabledOpacity,
    this.animationDuration = TurboFormsDefaults.animationDuration,
  });

  final Widget? label;
  final String? description;
  final TextStyle? descriptionStyle;
  final Widget? labelTrailing;
  final TFormFieldBuilderDef<T> builder;
  final TFormFieldConfig<T> formFieldConfig;
  final Widget? child;
  final EdgeInsets? errorPadding;
  final double? horizontalPadding;
  final TextStyle? errorTextStyle;
  final double disabledOpacity;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: formFieldConfig,
    builder: (context, listenableChild) {
      return StatelessTFormField(
        horizontalPadding: horizontalPadding,
        label: label,
        description: description,
        descriptionStyle: descriptionStyle,
        labelTrailing: labelTrailing,
        errorPadding: errorPadding,
        errorText: formFieldConfig.errorText,
        shouldValidate: formFieldConfig.shouldValidate,
        isEnabled: formFieldConfig.isEnabled,
        isReadOnly: formFieldConfig.isReadOnly,
        errorTextStyle: errorTextStyle,
        disabledOpacity: disabledOpacity,
        animationDuration: animationDuration,
        formFieldContent: TFormFieldBuilder(
          fieldConfig: formFieldConfig,
          builder: builder,
          child: child,
        ),
      );
    },
  );
}

/// A stateless form field layout widget with label, description, error, and
/// disabled/read-only state handling.
class StatelessTFormField extends StatelessWidget {
  const StatelessTFormField({
    super.key,
    this.label,
    this.description,
    this.descriptionStyle,
    this.labelTrailing,
    this.errorPadding,
    this.errorText,
    required this.shouldValidate,
    required this.isEnabled,
    required this.isReadOnly,
    required this.formFieldContent,
    required this.errorTextStyle,
    this.horizontalPadding,
    this.disabledOpacity = TurboFormsDefaults.defaultDisabledOpacity,
    this.animationDuration = TurboFormsDefaults.animationDuration,
  });

  final Widget? label;
  final String? description;
  final TextStyle? descriptionStyle;
  final Widget? labelTrailing;
  final EdgeInsets? errorPadding;
  final String? errorText;
  final bool shouldValidate;
  final bool isEnabled;
  final bool isReadOnly;
  final Widget formFieldContent;
  final double? horizontalPadding;
  final TextStyle? errorTextStyle;
  final double disabledOpacity;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final subLabel = description;

    return AnimatedOpacity(
      duration: animationDuration,
      opacity: isEnabled ? 1 : disabledOpacity,
      child: IgnorePointer(
        ignoring: !isEnabled || isReadOnly,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label != null || subLabel != null || labelTrailing != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (horizontalPadding != null)
                    SizedBox(width: horizontalPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (label != null) label!,
                        if (subLabel == null)
                          const SizedBox(height: 4)
                        else ...[
                          if (label != null) const SizedBox(height: 4),
                          Text(subLabel, style: descriptionStyle),
                        ],
                      ],
                    ),
                  ),
                  if (labelTrailing != null) ...[
                    if (label != null || subLabel != null)
                      const SizedBox(width: 8),
                    labelTrailing!,
                    const SizedBox(width: 8),
                  ],
                  if (horizontalPadding != null)
                    SizedBox(width: horizontalPadding),
                ],
              ),
              const SizedBox(height: 6),
            ],
            MouseRegion(
              cursor: SystemMouseCursors.text,
              child: formFieldContent,
            ),
            TErrorLabel(
              errorText: errorText,
              shouldValidate: shouldValidate,
              errorTextStyle: errorTextStyle,
              padding: errorPadding,
            ),
          ],
        ),
      ),
    );
  }
}
