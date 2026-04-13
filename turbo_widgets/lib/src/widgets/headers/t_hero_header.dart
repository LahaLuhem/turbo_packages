import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/widgets/content/t_metric_tile.dart';
import 'package:turbo_widgets/src/widgets/content/t_status_indicator.dart';

class THeroHeader extends StatelessWidget {
  const THeroHeader({
    super.key,
    required this.version,
    required this.title,
    this.subtitle,
    this.statusItems = const [],
    this.statusItemIsLive = const [],
    this.metricValues = const [],
    this.metricLabels = const [],
    this.metricUnits = const [],
    this.buildDate,
    this.codename,
  });

  final String version;
  final String title;
  final String? subtitle;
  final List<String> statusItems;
  final List<bool> statusItemIsLive;
  final List<String> metricValues;
  final List<String> metricLabels;
  final List<String> metricUnits;
  final String? buildDate;
  final String? codename;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusBar(
          statusItems: statusItems,
          statusItemIsLive: statusItemIsLive,
          buildDate: buildDate,
          codename: codename,
        ),
        const SizedBox(height: 64),
        _VersionSection(
          version: version,
          title: title,
          subtitle: subtitle,
        ),
        const SizedBox(height: 80),
        if (metricValues.isNotEmpty)
          _MetricsRow(
            values: metricValues,
            labels: metricLabels,
            units: metricUnits,
          ),
      ],
    );
  }
}

// -- Status Bar ---------------------------------------------------------------

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.statusItems,
    required this.statusItemIsLive,
    this.buildDate,
    this.codename,
  });

  final List<String> statusItems;
  final List<bool> statusItemIsLive;
  final String? buildDate;
  final String? codename;

  static const _zinc600 = Color(0xFF52525B);
  static const _zinc700 = Color(0xFF3F3F46);
  static const _cyan600 = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    const monoStyle = TextStyle(
      fontFamily: TFontFamilies.jetBrainsMono,
      fontSize: 10,
      letterSpacing: 3.0,
      fontWeight: FontWeight.w400,
      color: _zinc600,
    );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < statusItems.length; i++)
          TStatusIndicator(
            label: statusItems[i],
            isLive: i < statusItemIsLive.length && statusItemIsLive[i],
          ),
        if (statusItems.isNotEmpty)
          _Separator(style: monoStyle.copyWith(color: _zinc700)),
        if (buildDate != null) Text('BUILD $buildDate', style: monoStyle),
        _Separator(style: monoStyle.copyWith(color: _zinc700)),
        if (codename != null)
          Text(codename!, style: monoStyle.copyWith(color: _cyan600)),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator({required this.style});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text('|', style: style);
  }
}

// -- Version Section ----------------------------------------------------------

class _VersionSection extends StatelessWidget {
  const _VersionSection({
    required this.version,
    required this.title,
    this.subtitle,
  });

  final String version;
  final String title;
  final String? subtitle;

  static const _zinc500 = Color(0xFF71717A);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final width = MediaQuery.sizeOf(context).width;
    final versionFontSize = width >= 768
        ? 220.0
        : width >= 640
        ? 180.0
        : 120.0;
    final titleFontSize = width >= 768
        ? 48.0
        : width >= 640
        ? 36.0
        : 30.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          child: _VersionNumber(
            version: version,
            fontSize: versionFontSize,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: TFontFamilies.manrope,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: colors.heading,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 16),
          Text(
            subtitle!.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: TFontFamilies.jetBrainsMono,
              fontSize: 12,
              letterSpacing: 4.8,
              fontWeight: FontWeight.w400,
              color: _zinc500,
            ),
          ),
        ],
      ],
    );
  }
}

class _VersionNumber extends StatelessWidget {
  const _VersionNumber({
    required this.version,
    required this.fontSize,
  });

  final String version;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VersionNumberPainter(
        version: version,
        fontSize: fontSize,
      ),
      size: Size.zero,
      child: _VersionNumberSizer(
        version: version,
        fontSize: fontSize,
      ),
    );
  }
}

class _VersionNumberSizer extends StatelessWidget {
  const _VersionNumberSizer({
    required this.version,
    required this.fontSize,
  });

  final String version;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      version,
      style: TextStyle(
        fontFamily: TFontFamilies.jetBrainsMono,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        height: 1.0,
        letterSpacing: fontSize * -0.05,
        color: Colors.transparent,
      ),
    );
  }
}

class _VersionNumberPainter extends CustomPainter {
  _VersionNumberPainter({
    required this.version,
    required this.fontSize,
  });

  final String version;
  final double fontSize;

  @override
  void paint(Canvas canvas, Size size) {
    final sizeParag = _buildParagraph(null, size.width);

    // Layer 1: Ghost version — white gradient fill + stroke
    final ghostShader = ui.Gradient.linear(
      Offset.zero,
      Offset(0, sizeParag.height),
      [
        Colors.white.withValues(alpha: 0.15),
        Colors.white.withValues(alpha: 0.02),
      ],
    );

    canvas.save();
    final ghostFillParagraph = _buildParagraph(
      Paint()..shader = ghostShader,
      size.width,
    );
    canvas.drawParagraph(ghostFillParagraph, Offset.zero);

    final ghostStrokeParagraph = _buildParagraph(
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.1),
      size.width,
    );
    canvas.drawParagraph(ghostStrokeParagraph, Offset.zero);
    canvas.restore();

    // Layer 2: Cyan glow (painted behind the cyan gradient for depth)
    final glowParagraph = _buildParagraph(
      Paint()
        ..color = const Color(0xFF22D3EE).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      size.width,
    );
    canvas.drawParagraph(glowParagraph, Offset.zero);

    // Layer 3: Cyan gradient overlay
    final cyanShader = ui.Gradient.linear(
      Offset.zero,
      Offset(0, sizeParag.height),
      [
        const Color(0xFF22D3EE),
        const Color(0xFF06B6D4),
        const Color(0xFF0891B2),
      ],
      [0.0, 0.5, 1.0],
    );

    final cyanParagraph = _buildParagraph(
      Paint()..shader = cyanShader,
      size.width,
    );
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..blendMode = BlendMode.screen,
    );
    canvas.drawParagraph(cyanParagraph, Offset.zero);
    canvas.restore();
  }

  ui.Paragraph _buildParagraph(Paint? foreground, double maxWidth) {
    final style = ui.TextStyle(
      fontFamily: TFontFamilies.jetBrainsMono,
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 1.0,
      letterSpacing: fontSize * -0.05,
      foreground: foreground,
    );
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          )
          ..pushStyle(style)
          ..addText(version);
    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
    return paragraph;
  }

  @override
  bool shouldRepaint(_VersionNumberPainter oldDelegate) =>
      oldDelegate.version != version || oldDelegate.fontSize != fontSize;
}

// -- Metrics Row --------------------------------------------------------------

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.values,
    required this.labels,
    required this.units,
  });

  final List<String> values;
  final List<String> labels;
  final List<String> units;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final width = MediaQuery.sizeOf(context).width;
    final spacing = width >= 640 ? 64.0 : 32.0;
    final valueFontSize = width >= 640 ? 48.0 : 36.0;

    return Wrap(
      spacing: spacing,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < values.length; i++)
          TMetricTile(
            value: values[i],
            label: i < labels.length ? labels[i] : '',
            unit: i < units.length ? units[i] : null,
            valueStyle: TextStyle(
              fontFamily: TFontFamilies.jetBrainsMono,
              fontSize: valueFontSize,
              fontWeight: FontWeight.w900,
              color: colors.heading,
              height: 1.0,
            ),
          ),
      ],
    );
  }
}
