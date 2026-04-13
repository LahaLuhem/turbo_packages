import 'dart:math';

import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

extension BadgeColorExtensions on Color {
  /// Blend this color over [background], at [opacity], and return
  /// a fully-opaque composite.
  Color _compositeOn(Color background, double opacity) {
    final inv = 1.0 - opacity;
    return Color.fromARGB(
      0xFF,
      (((background.r * 255.0).round() & 0xff) * inv +
              ((r * 255.0).round() & 0xff) * opacity)
          .round(),
      (((background.g * 255.0).round() & 0xff) * inv +
              ((g * 255.0).round() & 0xff) * opacity)
          .round(),
      (((background.b * 255.0).round() & 0xff) * inv +
              ((b * 255.0).round() & 0xff) * opacity)
          .round(),
    );
  }

  /// Opaque badge background: your base color at 12% opacity over [surface].
  ///
  /// Defaults to a dark surface (#121212), but you can pass any surface.
  Color badgeBackground({Color surface = const Color(0xFF121212)}) =>
      _compositeOn(surface, 0.2);

  /// Opaque badge border: your base color at 64% opacity over [surface].
  Color badgeBorder({Color surface = const Color(0xFF121212)}) =>
      _compositeOn(surface, 0.64);

  /// The “on-badge” paint: exactly your base color.
  Color get badgeForeground => asSoftText;
}

extension MeshGradientPointListExtension on List<MeshGradientPoint> {
  /// Returns the appropriate text color (black or white) for the mesh gradient
  /// based on the average brightness of the colors in the list.
  ///
  /// ```dart
  /// final meshPoints = [MeshGradientPoint(color: Colors.blue), MeshGradientPoint(color: Colors.purple)];
  /// final textColor = meshPoints.onColor; // Returns white or black depending on brightness
  /// ```
  Color get onColor {
    // Calculate the average brightness of all colors in the list
    double totalBrightness = 0;
    for (final point in this) {
      final brightness = material.ThemeData.estimateBrightnessForColor(
        point.color,
      );
      totalBrightness += brightness == material.Brightness.light ? 1 : 0;
    }

    final averageBrightness = totalBrightness / length;
    // If average brightness is closer to light (>0.5), use black text, otherwise white
    return averageBrightness > 0.5 ? Colors.black : Colors.white;
  }

  /// Returns a high-contrast foreground color suitable for text and UI elements
  /// based on the mesh gradient's colors.
  ///
  /// The color maintains a hint of the gradient's hue while ensuring readability.
  ///
  /// ```dart
  /// final meshPoints = [MeshGradientPoint(color: Colors.blue), MeshGradientPoint(color: Colors.purple)];
  /// final foregroundColor = meshPoints.asForeground; // Returns a readable color with a hint of blue/purple
  /// ```
  Color get asForeground {
    // Calculate the average brightness, hue and saturation of all colors in the list
    double totalBrightness = 0;
    double totalHue = 0;
    double totalSaturation = 0;

    for (final point in this) {
      final HSLColor hsl = HSLColor.fromColor(point.color);
      final brightness = material.ThemeData.estimateBrightnessForColor(
        point.color,
      );

      totalBrightness += brightness == material.Brightness.light ? 1 : 0;
      totalHue += hsl.hue;
      totalSaturation += hsl.saturation;
    }

    final averageBrightness = totalBrightness / length;
    final averageHue = totalHue / length;
    final averageSaturation = totalSaturation / length;

    // Base color decision on brightness with higher contrast
    if (averageBrightness > 0.5) {
      // For light backgrounds, start with black and add a hint of the background's hue
      return HSLColor.fromAHSL(
        1.0,
        averageHue,
        min(
          0.4,
          averageSaturation * 0.5,
        ), // Keep saturation low for better contrast
        0.1, // Start very dark (near black)
      ).toColor();
    } else {
      // For dark backgrounds, start with white and add a hint of the background's hue
      return HSLColor.fromAHSL(
        1.0,
        averageHue,
        min(
          0.2,
          averageSaturation * 0.3,
        ), // Keep saturation very low for better contrast
        0.95, // Start very light (near white)
      ).toColor();
    }
  }
}

extension ColorExtension on Color {
  Color get asShadowVariant => withValues(alpha: 0.4);

  /// Blends two colors by averaging their HSV components.
  ///
  /// Handles the special case of hue wrapping around the color wheel.
  ///
  /// ```dart
  /// final blended = Colors.blue.merge(Colors.red); // Creates a purple color
  /// ```
  Color merge(Color other) {
    final HSVColor hsv1 = HSVColor.fromColor(this);
    final HSVColor hsv2 = HSVColor.fromColor(other);

    double hue;
    final double hueDiff = (hsv2.hue - hsv1.hue).abs();
    if (hueDiff > 180) {
      double hue1 = hsv1.hue;
      double hue2 = hsv2.hue;
      if (hue1 > hue2) {
        hue2 += 360;
      } else {
        hue1 += 360;
      }
      hue = ((hue1 + hue2) / 2) % 360;
    } else {
      hue = (hsv1.hue + hsv2.hue) / 2;
    }

    final double saturation = (hsv1.saturation + hsv2.saturation) / 2;
    final double value = (hsv1.value + hsv2.value) / 2;

    return HSVColor.fromAHSV(a, hue, saturation, value).toColor();
  }

  /// Returns either black or white depending on the brightness of this color.
  ///
  /// Useful for determining text color that will be readable on this background.
  Color get onColorBlackWhite =>
      material.ThemeData.estimateBrightnessForColor(this) ==
          material.Brightness.light
      ? Colors.black
      : Colors.white;

  /// Returns a high-contrast foreground color suitable for text and UI elements
  /// based on this background color.
  ///
  /// The returned color maintains a hint of the background's hue while ensuring readability.
  ///
  /// ```dart
  /// final backgroundColor = Colors.blue;
  /// final textColor = backgroundColor.onColor; // Returns a readable color with a hint of blue
  /// ```
  Color get onColor {
    final HSLColor hsl = HSLColor.fromColor(this);
    final bool isLight =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.light;

    if (isLight) {
      // For light backgrounds, start with black and add a hint of the background's hue
      return HSLColor.fromAHSL(
        1.0,
        hsl.hue,
        min(
          0.4,
          hsl.saturation * 0.5,
        ), // Keep saturation low for better contrast
        0.1, // Start very dark (near black)
      ).toColor();
    } else {
      // For dark backgrounds, start with white and add a hint of the background's hue
      return HSLColor.fromAHSL(
        1.0,
        hsl.hue,
        min(
          0.2,
          hsl.saturation * 0.3,
        ), // Keep saturation very low for better contrast
        1, // Start very light (near white)
      ).toColor();
    }
  }

  /// Creates a soft, subtle background color that works well for tags and badges.
  ///
  /// Adjusts for both light and dark themes to maintain visual harmony.
  ///
  /// ```dart
  /// final tagBackground = Colors.blue.asSoftBackground;
  /// ```
  Color get asSoftBackground {
    final HSLColor hsl = HSLColor.fromColor(this);
    final bool isLight =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.light;

    if (isLight) {
      // For light themes, create a very light, low-saturation background
      return HSLColor.fromAHSL(
        0.15, // Very transparent
        hsl.hue,
        min(0.7, hsl.saturation), // Preserve enough saturation to show color
        0.97, // Very light
      ).toColor();
    } else {
      // For dark themes, create a darker but still transparent background
      return HSLColor.fromAHSL(
        0.2, // Slightly more opacity for visibility
        hsl.hue,
        min(0.6, hsl.saturation), // Preserve color identity
        0.15, // Dark but not too dark
      ).toColor();
    }
  }

  /// Creates a soft border color that complements the background.
  ///
  /// Slightly more pronounced than the background but still subtle.
  ///
  /// ```dart
  /// final borderColor = Colors.blue.asSoftBorder;
  /// ```
  Color get asSoftBorder {
    final HSLColor hsl = HSLColor.fromColor(this);
    final bool isLight =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.light;

    if (isLight) {
      // For light themes, create a visible but soft border
      return HSLColor.fromAHSL(
        0.5, // Medium opacity
        hsl.hue,
        min(0.8, hsl.saturation * 1.2), // Slightly more saturated than original
        0.85, // Darker than background but still light
      ).toColor();
    } else {
      // For dark themes, create a subtle but visible border
      return HSLColor.fromAHSL(
        0.5, // Medium opacity
        hsl.hue,
        min(0.7, hsl.saturation * 1.1), // Slightly more saturated
        0.3, // Lighter than background but still dark
      ).toColor();
    }
  }

  /// Creates a color suitable for text that maintains the color identity
  /// while ensuring readability on the soft background.
  ///
  /// ```dart
  /// final textColor = Colors.blue.asSoftText;
  /// ```
  Color get asSoftText {
    final HSLColor hsl = HSLColor.fromColor(this);
    final bool isLight =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.light;

    if (isLight) {
      // For light themes, create a darker, more saturated text color
      return HSLColor.fromAHSL(
        1.0, // Full opacity for text
        hsl.hue,
        min(1.0, hsl.saturation * 1.3), // More saturated for emphasis
        max(0.2, hsl.lightness * 0.6), // Significantly darker for contrast
      ).toColor();
    } else {
      // For dark themes, create a brighter text color
      return HSLColor.fromAHSL(
        1.0, // Full opacity for text
        hsl.hue,
        min(1.0, hsl.saturation * 1.2), // More saturated
        min(0.8, hsl.lightness * 2.5), // Significantly lighter for contrast
      ).toColor();
    }
  }

  /// Brightens the color with the given integer percentage amount.
  ///
  /// ```dart
  /// final brighterBlue = Colors.blue.brighten(10); // 10% brighter
  /// ```
  Color brighten([final int amount = 5]) {
    if (amount <= 0) return this;
    if (amount > 100) return Colors.white;
    final Color color = Color.fromARGB(
      (a * 255.0).round() & 0xff,
      max(
        0,
        min(
          255,
          ((r * 255.0).round() & 0xff) - (255 * -(amount / 100)).round(),
        ),
      ),
      max(
        0,
        min(
          255,
          ((g * 255.0).round() & 0xff) - (255 * -(amount / 100)).round(),
        ),
      ),
      max(
        0,
        min(
          255,
          ((b * 255.0).round() & 0xff) - (255 * -(amount / 100)).round(),
        ),
      ),
    );
    // if (kDebugMode) {
    //   print('Brightened color: 0x${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}');
    // }
    return color;
  }

  /// Lightens the color with the given integer percentage amount.
  ///
  /// Handles black color specially to ensure it lightens properly along the grey scale.
  ///
  /// ```dart
  /// final lighterBlue = Colors.blue.lighten(20); // 20% lighter
  /// ```
  Color lighten([final int amount = 5, String? tag]) {
    if (amount <= 0) return this;
    if (amount > 100) return Colors.white;
    // HSLColor returns saturation 1 for black, we want 0 instead to be able
    // lighten black color up along the grey scale from black.
    final HSLColor hsl = this == const Color(0xFF000000)
        ? HSLColor.fromColor(this).withSaturation(0)
        : HSLColor.fromColor(this);
    final Color color = hsl
        .withLightness(min(1, max(0, hsl.lightness + amount / 100)))
        .toColor();
    // if (kDebugMode) {
    //   print('[$tag] Lightened color: 0x${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}');
    // }
    return color;
  }

  /// Darkens the color with the given integer percentage amount.
  ///
  /// ```dart
  /// final darkerBlue = Colors.blue.darken(15); // 15% darker
  /// ```
  Color darken([final int amount = 5, String? tag]) {
    if (amount <= 0) return this;
    if (amount > 100) return Colors.black;
    final HSLColor hsl = HSLColor.fromColor(this);
    final Color color = hsl
        .withLightness(min(1, max(0, hsl.lightness - amount / 100)))
        .toColor();
    // if (kDebugMode) {
    //   print('[$tag] Darkened color: 0x${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}');
    // }
    return color;
  }

  /// Returns either this color or its hover variant based on the hover state.
  ///
  /// ```dart
  /// final buttonColor = Colors.blue.withReactiveHover(isHovered: isHovering);
  /// ```
  Color withReactiveHover({required bool isHovered}) =>
      isHovered ? onHover : this;

  /// Returns a slightly darker or lighter version of this color suitable for backgrounds.
  ///
  /// Adjusts based on the color's brightness to maintain visual hierarchy.
  Color get onBackground {
    final bool isLight =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.light;

    if (isLight) {
      return darken(2);
      // final double newLightness = max(0, hsl.lightness - 0.05);
      // final double newSaturation = min(1, hsl.saturation + 0.01);
      // return hsl.withLightness(newLightness).withSaturation(newSaturation).toColor();
    } else {
      return lighten(2);
      // final double newLightness = min(1, hsl.lightness + 0.03);
      // final double newSaturation = min(1, hsl.saturation - 0.04);
      // return hsl.withLightness(newLightness).withSaturation(newSaturation).toColor();
    }
  }

  /// Returns a more pronounced darker or lighter version of this color for hover states.
  ///
  /// ```dart
  /// Container(
  ///   color: isHovered ? myColor.onHover : myColor,
  ///   child: Text('Hover me'),
  /// )
  /// ```
  Color get onHover {
    final bool isLight =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.light;

    if (isLight) {
      return darken(4);
      // final double newLightness = max(0, hsl.lightness - 0.05);
      // final double newSaturation = min(1, hsl.saturation + 0.01);
      // return hsl.withLightness(newLightness).withSaturation(newSaturation).toColor();
    } else {
      return lighten(4);
      // final double newLightness = min(1, hsl.lightness + 0.03);
      // final double newSaturation = min(1, hsl.saturation - 0.04);
      // return hsl.withLightness(newLightness).withSaturation(newSaturation).toColor();
    }
  }

  /// Converts the color to a subtle shadow suitable for use under icon buttons.
  ///
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     boxShadow: [Colors.blue.asShadow()],
  ///   ),
  ///   child: IconButton(...),
  /// )
  /// ```
  BoxShadow asShadow({
    double opacity = 0.3,
    Offset offset = const Offset(0, 2),
    double blurRadius = 4.0,
    double spreadRadius = 0.0,
  }) {
    // Adjust opacity based on color brightness for balanced shadows
    final bool isLight =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.light;

    // Darker colors need lower opacity to avoid heavy shadows
    final double adjustedOpacity = isLight ? opacity : opacity * 0.7;

    return BoxShadow(
      color: withValues(alpha: adjustedOpacity),
      offset: offset,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    );
  }

  /// Converts any color into a dark background color while maintaining its color identity.
  ///
  /// Bright colors become very dark with a tint of their original hue,
  /// while dark colors are adjusted to ensure they work well as backgrounds.
  ///
  /// ```dart
  /// final darkBg = Colors.blue.asDarkBackground; // Dark blue suitable for backgrounds
  /// ```
  Color get asDarkBackground {
    final HSLColor hsl = HSLColor.fromColor(this);
    final bool isLight =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.light;

    if (isLight) {
      // For light colors, create a very dark background with a subtle tint
      return HSLColor.fromAHSL(
        1.0,
        hsl.hue,
        // Reduce saturation significantly for light colors to create subtle tint
        min(0.3, hsl.saturation * 0.3),
        // Make it very dark but not pure black
        max(0.1, min(0.15, hsl.lightness * 0.15)),
      ).toColor();
    } else {
      // For already dark colors, adjust them to be suitable dark backgrounds
      return HSLColor.fromAHSL(
        1.0,
        hsl.hue,
        // Maintain or slightly enhance saturation for dark colors
        min(0.85, hsl.saturation * 1.2),
        // Ensure it stays dark but visible
        max(0.15, min(0.25, hsl.lightness * 1.2)),
      ).toColor();
    }
  }

  /// Converts the color to a gradient list with a lighter version of the color
  /// as the first element and the original color as the second element.
  ///
  /// ```dart
  /// final gradient = Colors.blue.asGradient();
  /// Container(
  ///   decoration: BoxDecoration(
  ///     gradient: LinearGradient(colors: gradient),
  ///   ),
  /// )
  /// ```
  List<Color> asGradient([amount = 10]) {
    return [lighten(amount), this];
  }

  /// Converts a color designed for dark mode to an equivalent
  /// that looks good on light mode (white background).
  ///
  /// Maintains the color's visual identity while ensuring sufficient contrast.
  ///
  /// ```dart
  /// // A color designed for dark theme
  /// final darkThemeColor = Color(0xFF5C6BC0);
  ///
  /// // Convert it for use on light theme
  /// final lightThemeColor = darkThemeColor.asLightModeColor;
  /// ```
  Color get asLightModeColor {
    final HSLColor hsl = HSLColor.fromColor(this);

    // Check if the color is already light enough for light mode
    final bool isDark =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.dark;

    if (!isDark) {
      // If the color is already light, make minor adjustments to ensure it works on white
      return HSLColor.fromAHSL(
        hsl.alpha,
        hsl.hue,
        min(
          1.0,
          hsl.saturation * 1.2,
        ), // Slightly increase saturation for visibility
        max(
          0.3,
          min(0.7, hsl.lightness),
        ), // Ensure lightness is in a good range for light mode
      ).toColor();
    }

    // For dark colors, we need more significant transformations

    // 1. Invert the lightness while preserving color identity
    double newLightness = 1.0 - hsl.lightness;

    // 2. Adjust lightness to ensure it's not too light or too dark
    // Colors that were very dark (near black) should be medium-dark in light mode
    // Colors that were medium-dark should be medium-light in light mode
    newLightness = max(0.35, min(0.85, newLightness));

    // 3. Adjust saturation to maintain visual impact
    // Darker colors often need higher saturation in light mode to maintain their character
    double saturationMultiplier = 1.0;
    if (hsl.lightness < 0.2) {
      // Very dark colors need more saturation boost
      saturationMultiplier = 1.4;
    } else if (hsl.lightness < 0.5) {
      // Medium-dark colors need moderate saturation boost
      saturationMultiplier = 1.2;
    }

    final double newSaturation = min(
      1.0,
      hsl.saturation * saturationMultiplier,
    );

    // 4. Create the light mode color
    return HSLColor.fromAHSL(
      hsl.alpha,
      hsl.hue,
      newSaturation,
      newLightness,
    ).toColor();
  }

  /// Converts a color designed for dark mode to one that looks good on a specific background color.
  ///
  /// Takes the actual background color into account to create a color that blends well
  /// while maintaining the original color's visual identity.
  ///
  /// ```dart
  /// // A color designed for dark theme
  /// final darkThemeColor = Color(0xFF5C6BC0);
  ///
  /// // Convert it for use on a specific light background
  /// final adaptedColor = darkThemeColor.asLightModeColorWithContext(
  ///   Color(0xFFF5F5F5),
  ///   contrastLevel: 0.7,
  /// );
  /// ```
  Color asLightModeColorWithContext(
    Color backgroundColor, {
    double contrastLevel = 0.5,
  }) {
    final HSLColor hsl = HSLColor.fromColor(this);
    final HSLColor bgHsl = HSLColor.fromColor(backgroundColor);

    // Determine if the background is light or dark
    final bool isBgLight =
        material.ThemeData.estimateBrightnessForColor(backgroundColor) ==
        material.Brightness.light;

    // Check if the color is already appropriate for the background
    final bool isColorDark =
        material.ThemeData.estimateBrightnessForColor(this) ==
        material.Brightness.dark;

    // If the color and background have opposite brightness, they might already have good contrast
    if (isColorDark == !isBgLight) {
      // Still make minor adjustments to ensure it blends well
      final double saturationAdjust = isBgLight ? 0.1 : -0.1;
      double lightnessAdjust = 0;

      // If background is very light or very dark, adjust lightness slightly
      if (bgHsl.lightness > 0.9) {
        lightnessAdjust = -0.05; // Darken slightly on very light backgrounds
      } else if (bgHsl.lightness < 0.1) {
        lightnessAdjust = 0.05; // Lighten slightly on very dark backgrounds
      }

      return HSLColor.fromAHSL(
        hsl.alpha,
        hsl.hue,
        min(1.0, max(0.0, hsl.saturation + saturationAdjust)),
        min(1.0, max(0.0, hsl.lightness + lightnessAdjust)),
      ).toColor();
    }

    // For more significant transformations, consider the background color's properties

    // 1. Calculate target lightness based on background lightness and desired contrast
    double targetLightness;
    if (isBgLight) {
      // On light backgrounds, we want darker colors with appropriate contrast
      // Higher contrastLevel means darker colors
      targetLightness = max(0.1, bgHsl.lightness - (0.3 + contrastLevel * 0.4));
    } else {
      // On dark backgrounds, we want lighter colors with appropriate contrast
      // Higher contrastLevel means lighter colors
      targetLightness = min(0.9, bgHsl.lightness + (0.3 + contrastLevel * 0.4));
    }

    // 2. Adjust saturation based on background saturation
    // If background is highly saturated, reduce saturation of the color to avoid clashing
    // If background is desaturated, we can keep more of the original saturation
    double saturationMultiplier = 1.0;
    if (bgHsl.saturation > 0.5) {
      saturationMultiplier =
          0.8; // Reduce saturation on highly saturated backgrounds
    } else if (bgHsl.saturation < 0.2) {
      saturationMultiplier = 1.2; // Boost saturation on desaturated backgrounds
    }

    // 3. Adjust hue slightly to complement the background if they're too similar
    double hueAdjust = 0;
    final double hueDifference = (hsl.hue - bgHsl.hue).abs();
    if (hueDifference < 30 || hueDifference > 330) {
      // If hues are too similar, shift slightly to create distinction
      hueAdjust = 15;
    }

    // 4. Create the context-aware color
    return HSLColor.fromAHSL(
      hsl.alpha,
      (hsl.hue + hueAdjust) % 360,
      min(1.0, max(0.0, hsl.saturation * saturationMultiplier)),
      targetLightness,
    ).toColor();
  }
}

extension ColorListExtension on List<Color> {
  /// Brightens all colors in the list with the given integer percentage amount.
  ///
  /// ```dart
  /// final brighterColors = [Colors.blue, Colors.red].brighten(10);
  /// ```
  List<Color> brighten([final int amount = 5]) {
    return map((color) => color.brighten(amount)).toList();
  }

  /// Lightens all colors in the list with the given integer percentage amount.
  ///
  /// ```dart
  /// final lighterColors = [Colors.blue, Colors.red].lighten(15);
  /// ```
  List<Color> lighten([final int amount = 5]) {
    return map((color) => color.lighten(amount)).toList();
  }

  /// Darkens all colors in the list with the given integer percentage amount.
  ///
  /// ```dart
  /// final darkerColors = [Colors.blue, Colors.red].darken(20);
  /// ```
  List<Color> darken([final int amount = 5]) {
    return map((color) => color.darken(amount)).toList();
  }

  /// Converts all colors in the list from dark mode to light mode.
  ///
  /// Assumes the colors were designed for dark backgrounds and converts them
  /// to equivalents that look good on light backgrounds.
  List<Color> get asLightModeColors {
    return map((color) => color.asLightModeColor).toList();
  }

  /// Converts all colors in the list from dark mode to colors that look good on a specific background.
  ///
  /// Takes the actual background color into account to create colors that blend well with that background.
  ///
  /// ```dart
  /// final adaptedColors = darkThemeColors.asLightModeColorsWithContext(
  ///   backgroundColor,
  ///   contrastLevel: 0.6,
  /// );
  /// ```
  List<Color> asLightModeColorsWithContext(
    Color backgroundColor, {
    double contrastLevel = 0.5,
  }) {
    return map(
      (color) => color.asLightModeColorWithContext(
        backgroundColor,
        contrastLevel: contrastLevel,
      ),
    ).toList();
  }

  /// Creates hover effects for all colors in the list.
  List<Color> get hovered {
    return map((color) => color.onHover).toList();
  }

  /// Returns either the original colors or their hover variants based on the hover state.
  List<Color> withReactiveHover({required bool isHovered}) =>
      isHovered ? hovered : this;

  /// Returns the appropriate text color (black or white) for the gradient
  /// based on the average brightness of the colors in the list.
  ///
  /// ```dart
  /// final textColor = [Colors.blue, Colors.purple].onColor;
  /// ```
  Color get onColor {
    // Calculate the average brightness of all colors in the list
    double totalBrightness = 0;
    for (final color in this) {
      final brightness = material.ThemeData.estimateBrightnessForColor(color);
      totalBrightness += brightness == material.Brightness.light ? 1 : 0;
    }

    final averageBrightness = totalBrightness / length;
    // If average brightness is closer to light (>0.5), use black text, otherwise white
    return averageBrightness > 0.5 ? Colors.black : Colors.white;
  }

  /// Returns a high-contrast foreground color suitable for text and UI elements
  /// based on the average of the colors in the list.
  ///
  /// ```dart
  /// final foregroundColor = [Colors.blue, Colors.purple].asForeground;
  /// ```
  Color get asForeground {
    // Calculate the average brightness, hue and saturation of all colors in the list
    double totalBrightness = 0;
    double totalHue = 0;
    double totalSaturation = 0;

    for (final color in this) {
      final HSLColor hsl = HSLColor.fromColor(color);
      final brightness = material.ThemeData.estimateBrightnessForColor(color);

      totalBrightness += brightness == material.Brightness.light ? 1 : 0;
      totalHue += hsl.hue;
      totalSaturation += hsl.saturation;
    }

    final averageBrightness = totalBrightness / length;
    final averageHue = totalHue / length;
    final averageSaturation = totalSaturation / length;

    // Base color decision on brightness with higher contrast
    if (averageBrightness > 0.5) {
      // For light backgrounds, start with black and add a hint of the background's hue
      return HSLColor.fromAHSL(
        1.0,
        averageHue,
        min(
          0.4,
          averageSaturation * 0.5,
        ), // Keep saturation low for better contrast
        0.1, // Start very dark (near black)
      ).toColor();
    } else {
      // For dark backgrounds, start with white and add a hint of the background's hue
      return HSLColor.fromAHSL(
        1.0,
        averageHue,
        min(
          0.2,
          averageSaturation * 0.3,
        ), // Keep saturation very low for better contrast
        0.95, // Start very light (near white)
      ).toColor();
    }
  }
}

extension GradientExtension on Gradient {
  /// Brightens the gradient colors with the given integer percentage amount.
  /// Defaults to 5%.
  Gradient brighten([final int amount = 5]) {
    if (this is LinearGradient) {
      final LinearGradient linearGradient = this as LinearGradient;
      return LinearGradient(
        colors: linearGradient.colors
            .map((color) => color.brighten(amount))
            .toList(),
        stops: linearGradient.stops,
        begin: linearGradient.begin,
        end: linearGradient.end,
        tileMode: linearGradient.tileMode,
        transform: linearGradient.transform,
      );
    } else if (this is RadialGradient) {
      final RadialGradient radialGradient = this as RadialGradient;
      return RadialGradient(
        colors: radialGradient.colors
            .map((color) => color.brighten(amount))
            .toList(),
        stops: radialGradient.stops,
        center: radialGradient.center,
        focal: radialGradient.focal,
        focalRadius: radialGradient.focalRadius,
        radius: radialGradient.radius,
        tileMode: radialGradient.tileMode,
        transform: radialGradient.transform,
      );
    } else if (this is SweepGradient) {
      final SweepGradient sweepGradient = this as SweepGradient;
      return SweepGradient(
        colors: sweepGradient.colors
            .map((color) => color.brighten(amount))
            .toList(),
        stops: sweepGradient.stops,
        center: sweepGradient.center,
        startAngle: sweepGradient.startAngle,
        endAngle: sweepGradient.endAngle,
        tileMode: sweepGradient.tileMode,
        transform: sweepGradient.transform,
      );
    }
    return this;
  }

  /// Lightens the gradient colors with the given integer percentage amount.
  /// Defaults to 5%.
  Gradient lighten([final int amount = 5]) {
    if (this is LinearGradient) {
      final LinearGradient linearGradient = this as LinearGradient;
      return LinearGradient(
        colors: linearGradient.colors
            .map((color) => color.lighten(amount))
            .toList(),
        stops: linearGradient.stops,
        begin: linearGradient.begin,
        end: linearGradient.end,
        tileMode: linearGradient.tileMode,
        transform: linearGradient.transform,
      );
    } else if (this is RadialGradient) {
      final RadialGradient radialGradient = this as RadialGradient;
      return RadialGradient(
        colors: radialGradient.colors
            .map((color) => color.lighten(amount))
            .toList(),
        stops: radialGradient.stops,
        center: radialGradient.center,
        focal: radialGradient.focal,
        focalRadius: radialGradient.focalRadius,
        radius: radialGradient.radius,
        tileMode: radialGradient.tileMode,
        transform: radialGradient.transform,
      );
    } else if (this is SweepGradient) {
      final SweepGradient sweepGradient = this as SweepGradient;
      return SweepGradient(
        colors: sweepGradient.colors
            .map((color) => color.lighten(amount))
            .toList(),
        stops: sweepGradient.stops,
        center: sweepGradient.center,
        startAngle: sweepGradient.startAngle,
        endAngle: sweepGradient.endAngle,
        tileMode: sweepGradient.tileMode,
        transform: sweepGradient.transform,
      );
    }
    return this;
  }

  /// Darkens the gradient colors with the given integer percentage amount.
  /// Defaults to 5%.
  Gradient darken([final int amount = 5]) {
    if (this is LinearGradient) {
      final LinearGradient linearGradient = this as LinearGradient;
      return LinearGradient(
        colors: linearGradient.colors
            .map((color) => color.darken(amount))
            .toList(),
        stops: linearGradient.stops,
        begin: linearGradient.begin,
        end: linearGradient.end,
        tileMode: linearGradient.tileMode,
        transform: linearGradient.transform,
      );
    } else if (this is RadialGradient) {
      final RadialGradient radialGradient = this as RadialGradient;
      return RadialGradient(
        colors: radialGradient.colors
            .map((color) => color.darken(amount))
            .toList(),
        stops: radialGradient.stops,
        center: radialGradient.center,
        focal: radialGradient.focal,
        focalRadius: radialGradient.focalRadius,
        radius: radialGradient.radius,
        tileMode: radialGradient.tileMode,
        transform: radialGradient.transform,
      );
    } else if (this is SweepGradient) {
      final SweepGradient sweepGradient = this as SweepGradient;
      return SweepGradient(
        colors: sweepGradient.colors
            .map((color) => color.darken(amount))
            .toList(),
        stops: sweepGradient.stops,
        center: sweepGradient.center,
        startAngle: sweepGradient.startAngle,
        endAngle: sweepGradient.endAngle,
        tileMode: sweepGradient.tileMode,
        transform: sweepGradient.transform,
      );
    }
    return this;
  }

  /// Converts a gradient designed for dark mode (dark background) to an equivalent
  /// that looks good on light mode (white background).
  ///
  /// This method assumes the input gradient was designed to look good on a dark background
  /// and transforms its colors to maintain their visual identity while ensuring they work well
  /// on a light background with sufficient contrast.
  Gradient get asLightModeGradient {
    if (this is LinearGradient) {
      final LinearGradient linearGradient = this as LinearGradient;
      return LinearGradient(
        colors: linearGradient.colors
            .map((color) => color.asLightModeColor)
            .toList(),
        stops: linearGradient.stops,
        begin: linearGradient.begin,
        end: linearGradient.end,
        tileMode: linearGradient.tileMode,
        transform: linearGradient.transform,
      );
    } else if (this is RadialGradient) {
      final RadialGradient radialGradient = this as RadialGradient;
      return RadialGradient(
        colors: radialGradient.colors
            .map((color) => color.asLightModeColor)
            .toList(),
        stops: radialGradient.stops,
        center: radialGradient.center,
        focal: radialGradient.focal,
        focalRadius: radialGradient.focalRadius,
        radius: radialGradient.radius,
        tileMode: radialGradient.tileMode,
        transform: radialGradient.transform,
      );
    } else if (this is SweepGradient) {
      final SweepGradient sweepGradient = this as SweepGradient;
      return SweepGradient(
        colors: sweepGradient.colors
            .map((color) => color.asLightModeColor)
            .toList(),
        stops: sweepGradient.stops,
        center: sweepGradient.center,
        startAngle: sweepGradient.startAngle,
        endAngle: sweepGradient.endAngle,
        tileMode: sweepGradient.tileMode,
        transform: sweepGradient.transform,
      );
    }
    return this;
  }

  /// Converts a gradient designed for dark mode to one that looks good on a specific background color.
  ///
  /// Unlike asLightModeGradient which assumes a white background, this method takes the actual
  /// background color into account to create a gradient that blends well with that specific background
  /// while maintaining the original gradient's visual identity.
  ///
  /// @param backgroundColor The background color that the resulting gradient will be displayed on
  /// @param contrastLevel Optional parameter to control the contrast level (0.0-1.0), defaults to 0.5
  Gradient asLightModeGradientWithContext(
    Color backgroundColor, {
    double contrastLevel = 0.5,
  }) {
    if (this is LinearGradient) {
      final LinearGradient linearGradient = this as LinearGradient;
      return LinearGradient(
        colors: linearGradient.colors
            .map(
              (color) => color.asLightModeColorWithContext(
                backgroundColor,
                contrastLevel: contrastLevel,
              ),
            )
            .toList(),
        stops: linearGradient.stops,
        begin: linearGradient.begin,
        end: linearGradient.end,
        tileMode: linearGradient.tileMode,
        transform: linearGradient.transform,
      );
    } else if (this is RadialGradient) {
      final RadialGradient radialGradient = this as RadialGradient;
      return RadialGradient(
        colors: radialGradient.colors
            .map(
              (color) => color.asLightModeColorWithContext(
                backgroundColor,
                contrastLevel: contrastLevel,
              ),
            )
            .toList(),
        stops: radialGradient.stops,
        center: radialGradient.center,
        focal: radialGradient.focal,
        focalRadius: radialGradient.focalRadius,
        radius: radialGradient.radius,
        tileMode: radialGradient.tileMode,
        transform: radialGradient.transform,
      );
    } else if (this is SweepGradient) {
      final SweepGradient sweepGradient = this as SweepGradient;
      return SweepGradient(
        colors: sweepGradient.colors
            .map(
              (color) => color.asLightModeColorWithContext(
                backgroundColor,
                contrastLevel: contrastLevel,
              ),
            )
            .toList(),
        stops: sweepGradient.stops,
        center: sweepGradient.center,
        startAngle: sweepGradient.startAngle,
        endAngle: sweepGradient.endAngle,
        tileMode: sweepGradient.tileMode,
        transform: sweepGradient.transform,
      );
    }
    return this;
  }

  /// Creates a sophisticated hover effect for gradients by:
  /// 1. Enhancing color vibrancy
  /// 2. Slightly shifting gradient positions
  /// 3. Adjusting color balance based on gradient type
  Gradient get hovered {
    if (this is LinearGradient) {
      final LinearGradient linearGradient = this as LinearGradient;

      // Create enhanced colors with subtle shifts in hue and saturation
      final List<Color> enhancedColors = linearGradient.colors.map((color) {
        final HSLColor hsl = HSLColor.fromColor(color);
        final bool isDark =
            material.ThemeData.estimateBrightnessForColor(color) ==
            material.Brightness.dark;

        // Adjust hue slightly to create a more vibrant effect
        final double hueShift = isDark ? 2.0 : -2.0;
        final double newHue = (hsl.hue + hueShift) % 360;

        // Adjust saturation and lightness based on color brightness
        final double saturationAdjust = isDark ? -0.05 : 0.08;
        final double lightnessAdjust = isDark ? 0.08 : -0.05;

        return hsl
            .withHue(newHue)
            .withSaturation(min(1, max(0, hsl.saturation + saturationAdjust)))
            .withLightness(min(1, max(0, hsl.lightness + lightnessAdjust)))
            .toColor();
      }).toList();

      // Slightly shift the gradient direction for a dynamic feel
      final Alignment adjustedBegin = _shiftAlignment(
        linearGradient.begin as Alignment,
        0.02,
      );
      final Alignment adjustedEnd = _shiftAlignment(
        linearGradient.end as Alignment,
        0.02,
      );

      return LinearGradient(
        colors: enhancedColors,
        stops: linearGradient.stops,
        begin: adjustedBegin,
        end: adjustedEnd,
        tileMode: linearGradient.tileMode,
        transform: linearGradient.transform,
      );
    } else if (this is RadialGradient) {
      final RadialGradient radialGradient = this as RadialGradient;

      // Create enhanced colors with subtle shifts in hue and saturation
      final List<Color> enhancedColors = radialGradient.colors.map((color) {
        final HSLColor hsl = HSLColor.fromColor(color);
        final bool isDark =
            material.ThemeData.estimateBrightnessForColor(color) ==
            material.Brightness.dark;

        // For radial gradients, we want a slightly different effect
        final double saturationAdjust = isDark ? -0.03 : 0.1;
        final double lightnessAdjust = isDark ? 0.1 : -0.03;

        return hsl
            .withSaturation(min(1, max(0, hsl.saturation + saturationAdjust)))
            .withLightness(min(1, max(0, hsl.lightness + lightnessAdjust)))
            .toColor();
      }).toList();

      // Slightly expand the radius for a "growing" hover effect
      final double adjustedRadius = radialGradient.radius * 1.05;

      return RadialGradient(
        colors: enhancedColors,
        stops: radialGradient.stops,
        center: radialGradient.center,
        focal: radialGradient.focal,
        focalRadius: radialGradient.focalRadius,
        radius: adjustedRadius,
        tileMode: radialGradient.tileMode,
        transform: radialGradient.transform,
      );
    } else if (this is SweepGradient) {
      final SweepGradient sweepGradient = this as SweepGradient;

      // Create enhanced colors with subtle shifts in hue and saturation
      final List<Color> enhancedColors = sweepGradient.colors.map((color) {
        final HSLColor hsl = HSLColor.fromColor(color);
        final bool isDark =
            material.ThemeData.estimateBrightnessForColor(color) ==
            material.Brightness.dark;

        // For sweep gradients, create a more pronounced effect
        final double hueShift = isDark ? 3.0 : -3.0;
        final double newHue = (hsl.hue + hueShift) % 360;

        final double saturationAdjust = isDark ? -0.05 : 0.08;
        final double lightnessAdjust = isDark ? 0.08 : -0.04;

        return hsl
            .withHue(newHue)
            .withSaturation(min(1, max(0, hsl.saturation + saturationAdjust)))
            .withLightness(min(1, max(0, hsl.lightness + lightnessAdjust)))
            .toColor();
      }).toList();

      // Slightly rotate the sweep for a dynamic hover effect
      const double angleAdjust = 0.05; // Small rotation

      return SweepGradient(
        colors: enhancedColors,
        stops: sweepGradient.stops,
        center: sweepGradient.center,
        startAngle: sweepGradient.startAngle + angleAdjust,
        endAngle: sweepGradient.endAngle + angleAdjust,
        tileMode: sweepGradient.tileMode,
        transform: sweepGradient.transform,
      );
    }
    return this;
  }

  // Helper method to shift alignment slightly for hover effects
  Alignment _shiftAlignment(Alignment alignment, double amount) {
    return Alignment(
      alignment.x + (alignment.x > 0 ? amount : -amount),
      alignment.y + (alignment.y > 0 ? amount : -amount),
    );
  }

  /// Returns a high-contrast foreground color suitable for text and UI elements
  /// based on the gradient's colors.
  Color get asForeground {
    if (this is LinearGradient) {
      final LinearGradient linearGradient = this as LinearGradient;
      return linearGradient.colors.asForeground;
    } else if (this is RadialGradient) {
      final RadialGradient radialGradient = this as RadialGradient;
      return radialGradient.colors.asForeground;
    } else if (this is SweepGradient) {
      final SweepGradient sweepGradient = this as SweepGradient;
      return sweepGradient.colors.asForeground;
    }
    // Fallback to a safe color if gradient type is unknown
    return Colors.white;
  }
}
