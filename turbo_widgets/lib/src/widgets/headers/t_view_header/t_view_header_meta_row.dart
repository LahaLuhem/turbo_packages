import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/widgets/headers/t_view_header/t_view_header_location_button.dart';

class TViewHeaderMetaRow extends StatelessWidget {
  const TViewHeaderMetaRow({
    super.key,
    required this.metaCount,
    required this.locationNames,
    required this.onLocationTap,
    this.metaLabel = 'PROPERTIES',
    this.isSmall = false,
    this.isMedium = false,
  });

  final int metaCount;
  final String metaLabel;
  final List<String> locationNames;
  final ValueChanged<int> onLocationTap;
  final bool isSmall;
  final bool isMedium;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: Color(0x0DFFFFFF)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: isSmall ? 12 : 16),
        child: isSmall
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PropertiesCount(
                    metaCount: metaCount,
                    metaLabel: metaLabel,
                    isSmall: true,
                  ),
                  if (locationNames.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _LocationsSection(
                      locationNames: locationNames,
                      onLocationTap: onLocationTap,
                      isSmall: true,
                    ),
                  ],
                ],
              )
            : Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: isMedium ? 24 : 32,
                runSpacing: 16,
                children: [
                  _PropertiesCount(
                    metaCount: metaCount,
                    metaLabel: metaLabel,
                    isSmall: false,
                  ),
                  if (locationNames.isNotEmpty) ...[
                    const SizedBox(
                      height: 32,
                      width: 1,
                      child: ColoredBox(color: Color(0x1AFFFFFF)),
                    ),
                    _LocationsSection(
                      locationNames: locationNames,
                      onLocationTap: onLocationTap,
                      isSmall: false,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _PropertiesCount extends StatelessWidget {
  const _PropertiesCount({
    required this.metaCount,
    required this.metaLabel,
    required this.isSmall,
  });

  final int metaCount;
  final String metaLabel;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final iconBoxSize = isSmall ? 28.0 : 32.0;
    final iconPixelSize = isSmall ? 12.0 : 14.0;
    final labelFontSize = isSmall ? 9.0 : 10.0;
    final valueFontSize = isSmall ? 12.0 : 14.0;
    final gap = isSmall ? 8.0 : 12.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconBoxSize,
          height: iconBoxSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              border: Border.all(width: 1, color: const Color(0x1AFFFFFF)),
            ),
            child: Center(
              child: Icon(
                Icons.storage_outlined,
                size: iconPixelSize,
                color: const Color(0xFF71717A),
              ),
            ),
          ),
        ),
        SizedBox(width: gap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              metaLabel,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF52525B),
                letterSpacing: 0.8,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$metaCount Items',
              style: TextStyle(
                fontFamily: TFontFamilies.jetBrainsMono,
                fontSize: valueFontSize,
                color: TColors.textPrimaryDark,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationsSection extends StatelessWidget {
  const _LocationsSection({
    required this.locationNames,
    required this.onLocationTap,
    required this.isSmall,
  });

  final List<String> locationNames;
  final ValueChanged<int> onLocationTap;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final labelFontSize = isSmall ? 9.0 : 10.0;
    final buttonGap = isSmall ? 6.0 : 8.0;

    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LOCATIONS',
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF52525B),
              letterSpacing: 0.8,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: buttonGap,
            runSpacing: buttonGap,
            children: [
              for (int i = 0; i < locationNames.length; i++)
                TViewHeaderLocationButton(
                  label: locationNames[i],
                  onTap: () => onLocationTap(i),
                  isSmall: true,
                ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'LOCATIONS',
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF52525B),
            letterSpacing: 0.8,
            height: 1,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Wrap(
            spacing: buttonGap,
            runSpacing: buttonGap,
            children: [
              for (int i = 0; i < locationNames.length; i++)
                TViewHeaderLocationButton(
                  label: locationNames[i],
                  onTap: () => onLocationTap(i),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
