import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A widget that displays a markdown file with a preview and a button to open it.
///
/// This widget shows:
/// - The file name
/// - A preview of the markdown content
/// - A button to open the file in an external app
class TMarkdownFileItem extends StatelessWidget {
  const TMarkdownFileItem({
    required this.fileName,
    required this.content,
    required this.onOpen,
    super.key,
    this.maxPreviewLines = 5,
  });

  /// The name of the markdown file.
  final String fileName;

  /// The content of the markdown file.
  final String content;

  /// Callback invoked when the open button is pressed.
  final VoidCallback onOpen;

  /// Maximum number of lines to show in the preview.
  final int maxPreviewLines;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _MarkdownFileHeader(
            fileName: fileName,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _MarkdownPreview(
            content: content,
            maxPreviewLines: maxPreviewLines,
            theme: theme,
          ),
          const SizedBox(height: 12),
          ShadButton(
            onPressed: onOpen,
            leading: const Icon(LucideIcons.externalLink, size: 16),
            child: const Text('Open in App'),
          ),
        ],
      ),
    );
  }
}

class _MarkdownFileHeader extends StatelessWidget {
  const _MarkdownFileHeader({
    required this.fileName,
    required this.theme,
  });

  final String fileName;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          LucideIcons.fileText,
          size: 20,
          color: theme.colorScheme.mutedForeground,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            fileName,
            style: theme.textTheme.small.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MarkdownPreview extends StatelessWidget {
  const _MarkdownPreview({
    required this.content,
    required this.maxPreviewLines,
    required this.theme,
  });

  final String content;
  final int maxPreviewLines;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final previewLines = lines.take(maxPreviewLines).toList();
    final hasMore = lines.length > maxPreviewLines;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.border,
          width: 1,
        ),
      ),
      constraints: const BoxConstraints(
        minHeight: 80,
        maxHeight: 200,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...previewLines.map(
              (line) => _MarkdownLine(
                line: line,
                theme: theme,
              ),
            ),
            if (hasMore) _MarkdownMoreIndicator(theme: theme),
          ],
        ),
      ),
    );
  }
}

class _MarkdownLine extends StatelessWidget {
  const _MarkdownLine({
    required this.line,
    required this.theme,
  });

  final String line;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (line.trim().isEmpty) {
      return const _MarkdownEmptyLine();
    }

    if (line.startsWith('# ')) {
      return _MarkdownHeader1(
        text: line.substring(2),
        theme: theme,
      );
    }

    if (line.startsWith('## ')) {
      return _MarkdownHeader2(
        text: line.substring(3),
        theme: theme,
      );
    }

    if (line.startsWith('### ')) {
      return _MarkdownHeader3(
        text: line.substring(4),
        theme: theme,
      );
    }

    if (line.contains('**') && line.split('**').length >= 3) {
      return _MarkdownBoldText(
        line: line,
        theme: theme,
      );
    }

    if (line.trim().startsWith('```')) {
      return _MarkdownCodeBlock(
        line: line,
        theme: theme,
      );
    }

    return _MarkdownRegularText(
      text: line,
      theme: theme,
    );
  }
}

class _MarkdownEmptyLine extends StatelessWidget {
  const _MarkdownEmptyLine();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 4);
  }
}

class _MarkdownHeader1 extends StatelessWidget {
  const _MarkdownHeader1({
    required this.text,
    required this.theme,
  });

  final String text;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.large.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MarkdownHeader2 extends StatelessWidget {
  const _MarkdownHeader2({
    required this.text,
    required this.theme,
  });

  final String text;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.small.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MarkdownHeader3 extends StatelessWidget {
  const _MarkdownHeader3({
    required this.text,
    required this.theme,
  });

  final String text;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.small.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MarkdownBoldText extends StatelessWidget {
  const _MarkdownBoldText({
    required this.line,
    required this.theme,
  });

  final String line;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    final parts = line.split('**');

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.small.copyWith(
            color: theme.colorScheme.foreground,
          ),
          children: [
            for (int i = 0; i < parts.length; i++)
              TextSpan(
                text: parts[i],
                style: i.isOdd
                    ? theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground,
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _MarkdownCodeBlock extends StatelessWidget {
  const _MarkdownCodeBlock({
    required this.line,
    required this.theme,
  });

  final String line;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          line.replaceAll('```', ''),
          style: theme.textTheme.small.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}

class _MarkdownRegularText extends StatelessWidget {
  const _MarkdownRegularText({
    required this.text,
    required this.theme,
  });

  final String text;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.small.copyWith(
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }
}

class _MarkdownMoreIndicator extends StatelessWidget {
  const _MarkdownMoreIndicator({
    required this.theme,
  });

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '...',
        style: theme.textTheme.small.copyWith(
          color: theme.colorScheme.mutedForeground,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
