import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/typedefs/t_update_current_def.dart';

extension TextStyleExtensionExtension on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle withColor(Color color) => copyWith(color: color);

  TextStyle copyWithCurrent({
    TUpdateCurrentDef<Color>? color,
    TUpdateCurrentDef<Color>? backgroundColor,
    TUpdateCurrentDef<double>? fontSize,
    TUpdateCurrentDef<FontWeight>? fontWeight,
    TUpdateCurrentDef<FontStyle>? fontStyle,
    TUpdateCurrentDef<double>? letterSpacing,
    TUpdateCurrentDef<double>? wordSpacing,
    TUpdateCurrentDef<TextBaseline>? textBaseline,
    TUpdateCurrentDef<double>? height,
    TUpdateCurrentDef<String>? fontFamily,
    TUpdateCurrentDef<TextOverflow>? overflow,
  }) {
    return copyWith(
      color: color?.call(this.color!),
      backgroundColor: backgroundColor?.call(this.backgroundColor!),
      fontSize: fontSize?.call(this.fontSize!),
      fontWeight: fontWeight?.call(this.fontWeight ?? FontWeight.normal),
      fontStyle: fontStyle?.call(this.fontStyle!),
      letterSpacing: letterSpacing?.call(this.letterSpacing!),
      wordSpacing: wordSpacing?.call(this.wordSpacing!),
      textBaseline: textBaseline?.call(this.textBaseline!),
      height: height?.call(this.height!),
      fontFamily: fontFamily?.call(this.fontFamily!),
      overflow: overflow?.call(this.overflow!),
    );
  }
}

extension AutoSizeTextExtension on AutoSizeText {
  AutoSizeText merge(TextStyle textStyle) => AutoSizeText(
    data!,
    style: textStyle.merge(style),
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    softWrap: softWrap,
    key: key,
    locale: locale,
    textDirection: textDirection,
    semanticsLabel: semanticsLabel,
    strutStyle: strutStyle,
    group: group,
    maxFontSize: maxFontSize,
    minFontSize: minFontSize,
    overflowReplacement: overflowReplacement,
    presetFontSizes: presetFontSizes,
    stepGranularity: stepGranularity,
    textKey: textKey,
    textScaleFactor: textScaleFactor,
    wrapWords: wrapWords,
  );
}

extension TextExtension on Text {
  Text merge(TextStyle textStyle) => Text(
    data!,
    style: textStyle.merge(style),
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    softWrap: softWrap,
    key: key,
    selectionColor: selectionColor,
    locale: locale,
    textDirection: textDirection,
    textHeightBehavior: textHeightBehavior,
    textScaler: textScaler,
    semanticsLabel: semanticsLabel,
    strutStyle: strutStyle,
    textWidthBasis: textWidthBasis,
  );
}
