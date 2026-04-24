import 'package:flutter/material.dart';
import 'package:turbo_forms/src/constants/turbo_forms_defaults.dart';
import 'package:turbo_forms/src/widgets/vertical_shrink.dart';

/// Animated error label that expands/collapses based on validation state.
class TErrorLabel extends StatelessWidget {
  const TErrorLabel({
    required String? errorText,
    required bool shouldValidate,
    this.errorTextStyle,
    this.padding,
    super.key,
  }) : _errorText = errorText,
       _shouldValidate = shouldValidate;

  final String? _errorText;
  final bool _shouldValidate;
  final TextStyle? errorTextStyle;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => VerticalShrink(
    alignment: Alignment.bottomCenter,
    fadeDuration: TurboFormsDefaults.animationDurationHalf,
    sizeDuration: TurboFormsDefaults.animationDurationHalf,
    show: _shouldValidate && (_errorText?.isNotEmpty == true),
    child: Padding(
      padding: padding ?? TurboFormsDefaults.defaultErrorPadding,
      child: Row(
        children: [
          Flexible(child: Text(_errorText ?? '', style: errorTextStyle)),
        ],
      ),
    ),
  );
}
