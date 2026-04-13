import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';

class TMetadataFooter extends StatelessWidget {
  const TMetadataFooter({
    super.key,
    required this.items,
    this.itemColors = const [],
    this.tagline,
    this.separator = '\u2022',
  });

  final List<String> items;
  final List<Color?> itemColors;
  final String? tagline;
  final String separator;

  static const _zinc600 = Color(0xFF52525B);
  static const _zinc700 = Color(0xFF3F3F46);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            color: Colors.white.withValues(alpha: 0.01),
          ),
          child: _MetadataRow(
            items: items,
            itemColors: itemColors,
            separator: separator,
            defaultColor: _zinc600,
            separatorColor: _zinc700,
          ),
        ),
        if (tagline != null) ...[
          const SizedBox(height: 24),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: TFontFamilies.jetBrainsMono,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w400,
              color: _zinc700,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.items,
    required this.itemColors,
    required this.separator,
    required this.defaultColor,
    required this.separatorColor,
  });

  final List<String> items;
  final List<Color?> itemColors;
  final String separator;
  final Color defaultColor;
  final Color separatorColor;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(
          Text(
            separator,
            style: TextStyle(
              fontFamily: TFontFamilies.jetBrainsMono,
              fontSize: 10,
              color: separatorColor,
            ),
          ),
        );
      }
      children.add(
        Text(
          items[i],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: TFontFamilies.jetBrainsMono,
            fontSize: 10,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w400,
            color:
                (i < itemColors.length ? itemColors[i] : null) ?? defaultColor,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: children,
    );
  }
}
