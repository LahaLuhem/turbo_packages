import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/responsive/enums/t_device_type.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/widgets/cards/t_card_shell.dart';
import 'package:turbo_widgets/src/widgets/headers/t_view_header/t_view_header_edit_button.dart';
import 'package:turbo_widgets/src/widgets/headers/t_view_header/t_view_header_glow_painter.dart';
import 'package:turbo_widgets/src/widgets/headers/t_view_header/t_view_header_meta_row.dart';
import 'package:turbo_widgets/src/widgets/headers/t_view_header/t_view_header_thumbnail.dart';
import 'package:turbo_widgets/src/widgets/headers/t_view_header/t_view_header_type_label.dart';

class TViewHeader extends StatelessWidget {
  const TViewHeader({
    super.key,
    required this.title,
    required this.typeLabel,
    required this.description,
    required this.metaCount,
    required this.icon,
    required this.onEdit,
    required this.locationNames,
    required this.onLocationTap,
    this.metaLabel = 'PROPERTIES',
    this.emoji,
    this.onEmojiChanged,
  });

  final String title;
  final String typeLabel;
  final String description;
  final int metaCount;
  final String metaLabel;
  final IconData icon;
  final VoidCallback onEdit;
  final List<String> locationNames;
  final ValueChanged<int> onLocationTap;
  final String? emoji;
  final ValueChanged<String>? onEmojiChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = context.deviceType;

        final containerPadding = switch (deviceType) {
          TDeviceType.mobile => 20.0,
          TDeviceType.tablet || TDeviceType.desktop => 40.0,
        };
        final bracketSize = switch (deviceType) {
          TDeviceType.mobile => 12.0,
          TDeviceType.tablet || TDeviceType.desktop => 16.0,
        };
        final glowDiameter = switch (deviceType) {
          TDeviceType.mobile => 256.0,
          TDeviceType.tablet || TDeviceType.desktop => 384.0,
        };
        final glowOffset = switch (deviceType) {
          TDeviceType.mobile => const Offset(-40, -40),
          TDeviceType.tablet || TDeviceType.desktop => const Offset(-80, -80),
        };

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: glowOffset.dy,
              left: glowOffset.dx,
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size.square(glowDiameter),
                  painter: TViewHeaderGlowPainter(
                    glowDiameter: glowDiameter,
                    glowOffset: Offset.zero,
                    glowColor: TColors.primaryDark.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
            RepaintBoundary(
              child: TCardShell(
                backgroundColor: const Color(0xFF09090B).withValues(alpha: 0.5),
                borderColor: const Color(0x1AFFFFFF),
                bracketSize: bracketSize,
                bracketColor: TColors.primaryDark.withValues(alpha: 0.3),
                showBackdropBlur: true,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(containerPadding),
                      child: switch (deviceType) {
                        TDeviceType.mobile => _TViewHeaderColumnLayout(
                          icon: icon,
                          emoji: emoji,
                          onEmojiChanged: onEmojiChanged,
                          title: title,
                          typeLabel: typeLabel,
                          description: description,
                          metaCount: metaCount,
                          metaLabel: metaLabel,
                          locationNames: locationNames,
                          onLocationTap: onLocationTap,
                        ),
                        TDeviceType.tablet ||
                        TDeviceType.desktop => _TViewHeaderRowLayout(
                          icon: icon,
                          emoji: emoji,
                          onEmojiChanged: onEmojiChanged,
                          title: title,
                          typeLabel: typeLabel,
                          description: description,
                          metaCount: metaCount,
                          metaLabel: metaLabel,
                          locationNames: locationNames,
                          onLocationTap: onLocationTap,
                          deviceType: deviceType,
                        ),
                      },
                    ),
                    Positioned(
                      top: containerPadding,
                      right: containerPadding,
                      child: TViewHeaderEditButton(onTap: onEdit),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TViewHeaderRowLayout extends StatelessWidget {
  const _TViewHeaderRowLayout({
    required this.icon,
    required this.title,
    required this.typeLabel,
    required this.description,
    required this.metaCount,
    required this.metaLabel,
    required this.locationNames,
    required this.onLocationTap,
    required this.deviceType,
    this.emoji,
    this.onEmojiChanged,
  });

  final IconData icon;
  final String? emoji;
  final ValueChanged<String>? onEmojiChanged;
  final String title;
  final String typeLabel;
  final String description;
  final int metaCount;
  final String metaLabel;
  final List<String> locationNames;
  final ValueChanged<int> onLocationTap;
  final TDeviceType deviceType;

  static const _thumbnailSize = 128.0;
  static const _thumbnailIconSize = 48.0;
  static const _emojiFontSize = 60.0;
  static const _contentGap = 40.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TViewHeaderThumbnail(
          size: _thumbnailSize,
          iconSize: _thumbnailIconSize,
          emojiFontSize: _emojiFontSize,
          icon: icon,
          emoji: emoji,
          onEmojiChanged: onEmojiChanged,
        ),
        const SizedBox(width: _contentGap),
        Expanded(
          child: _RightColumn(
            title: title,
            typeLabel: typeLabel,
            description: description,
            metaCount: metaCount,
            metaLabel: metaLabel,
            locationNames: locationNames,
            onLocationTap: onLocationTap,
            deviceType: deviceType,
          ),
        ),
      ],
    );
  }
}

class _TViewHeaderColumnLayout extends StatelessWidget {
  const _TViewHeaderColumnLayout({
    required this.icon,
    required this.title,
    required this.typeLabel,
    required this.description,
    required this.metaCount,
    required this.metaLabel,
    required this.locationNames,
    required this.onLocationTap,
    this.emoji,
    this.onEmojiChanged,
  });

  final IconData icon;
  final String? emoji;
  final ValueChanged<String>? onEmojiChanged;
  final String title;
  final String typeLabel;
  final String description;
  final int metaCount;
  final String metaLabel;
  final List<String> locationNames;
  final ValueChanged<int> onLocationTap;

  static const _thumbnailSize = 96.0;
  static const _thumbnailIconSize = 40.0;
  static const _emojiFontSize = 48.0;
  static const _contentGap = 24.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TViewHeaderThumbnail(
          size: _thumbnailSize,
          iconSize: _thumbnailIconSize,
          emojiFontSize: _emojiFontSize,
          icon: icon,
          emoji: emoji,
          onEmojiChanged: onEmojiChanged,
        ),
        const SizedBox(height: _contentGap),
        _RightColumn(
          title: title,
          typeLabel: typeLabel,
          description: description,
          metaCount: metaCount,
          metaLabel: metaLabel,
          locationNames: locationNames,
          onLocationTap: onLocationTap,
          deviceType: TDeviceType.mobile,
        ),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  const _RightColumn({
    required this.title,
    required this.typeLabel,
    required this.description,
    required this.metaCount,
    required this.metaLabel,
    required this.locationNames,
    required this.onLocationTap,
    required this.deviceType,
  });

  final String title;
  final String typeLabel;
  final String description;
  final int metaCount;
  final String metaLabel;
  final List<String> locationNames;
  final ValueChanged<int> onLocationTap;
  final TDeviceType deviceType;

  @override
  Widget build(BuildContext context) {
    final isSmall = switch (deviceType) {
      TDeviceType.mobile => true,
      TDeviceType.tablet || TDeviceType.desktop => false,
    };
    final typeLabelGap = switch (deviceType) {
      TDeviceType.mobile => 6.0,
      TDeviceType.tablet || TDeviceType.desktop => 8.0,
    };
    final afterTitleGap = switch (deviceType) {
      TDeviceType.mobile => 16.0,
      TDeviceType.tablet || TDeviceType.desktop => 24.0,
    };
    final afterDescriptionGap = switch (deviceType) {
      TDeviceType.mobile => 16.0,
      TDeviceType.tablet || TDeviceType.desktop => 24.0,
    };
    final titleFontSize = switch (deviceType) {
      TDeviceType.mobile => 30.0,
      TDeviceType.tablet || TDeviceType.desktop => 48.0,
    };
    final descriptionFontSize = switch (deviceType) {
      TDeviceType.mobile => 15.0,
      TDeviceType.tablet || TDeviceType.desktop => 18.0,
    };
    final descriptionPaddingLeft = switch (deviceType) {
      TDeviceType.mobile => 14.0,
      TDeviceType.tablet || TDeviceType.desktop => 24.0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TViewHeaderTypeLabel(
          label: typeLabel,
          isSmall: isSmall,
        ),
        SizedBox(height: typeLabelGap),
        Text(
          title,
          softWrap: true,
          style: TextStyle(
            fontFamily: TFontFamilies.manrope,
            fontWeight: FontWeight.w500,
            fontSize: titleFontSize,
            color: const Color(0xFFFAFAFA),
            letterSpacing: -0.4,
            height: 1.2,
          ),
        ),
        SizedBox(height: afterTitleGap),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 2,
                  color: Color(0x1AFFFFFF),
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: descriptionPaddingLeft),
              child: Text(
                description,
                style: TextStyle(
                  fontFamily: TFontFamilies.inter,
                  fontWeight: FontWeight.w300,
                  fontSize: descriptionFontSize,
                  color: const Color(0xFFA1A1AA),
                  height: 1.625,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: afterDescriptionGap),
        TViewHeaderMetaRow(
          metaCount: metaCount,
          metaLabel: metaLabel,
          locationNames: locationNames,
          onLocationTap: onLocationTap,
          isSmall: isSmall,
          isMedium: false,
        ),
      ],
    );
  }
}
