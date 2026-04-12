import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/widgets/detail/t_key_value_field.dart';

class TDetailHeader extends StatelessWidget {
  const TDetailHeader({
    required this.title,
    required this.description,
    super.key,
    this.metadata = const [],
    this.onSave,
    this.saveLabel = 'Save',
    this.metadataSpacing = 16,
    this.metadataRunSpacing = 8,
  });

  final String title;
  final String description;
  final List<TKeyValueField> metadata;
  final VoidCallback? onSave;
  final String saveLabel;
  final double metadataSpacing;
  final double metadataRunSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final showSave = onSave != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TDetailHeaderContent(
                title: title,
                description: description,
                theme: theme,
              ),
            ),
            if (showSave) ...[
              const SizedBox(width: 12),
              ShadButton(
                onPressed: onSave,
                child: Text(saveLabel),
              ),
            ],
          ],
        ),
        if (metadata.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: metadataSpacing,
            runSpacing: metadataRunSpacing,
            children: metadata,
          ),
        ],
      ],
    );
  }
}

class _TDetailHeaderContent extends StatelessWidget {
  const _TDetailHeaderContent({
    required this.title,
    required this.description,
    required this.theme,
  });

  final String title;
  final String description;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.large.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}
