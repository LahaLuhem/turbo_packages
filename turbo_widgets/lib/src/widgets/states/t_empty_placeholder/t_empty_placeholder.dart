import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';

/// A reusable widget for displaying an empty or "no data" state.
///
/// App-specific widgets (image renderers, action buttons, layout wrappers)
/// are injected via constructor parameters rather than hard-coded imports.
class TEmptyPlaceholder extends StatelessWidget {
  /// Creates a stateless widget that displays a friendly empty-view message.
  const TEmptyPlaceholder({
    super.key,
    required this.title,
    this.subtitle,
    this.iconData,
    this.imageWidget,
    this.actionLabel,
    this.onActionPressed,
    this.actionSemanticIdentifier,
    this.actionButtonBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  }) : assert(
         iconData == null || imageWidget == null,
         'Provide only iconData OR imageWidget, not both.',
       );

  /// Main heading text, e.g. "No items found"
  final String title;

  /// Optional secondary text, e.g. "Add a new item to get started"
  final String? subtitle;

  /// Optionally show an icon (instead of imageWidget).
  final IconData? iconData;

  /// Optional image widget to display (replaces the old imageAsset + TImage).
  final Widget? imageWidget;

  /// Text for the optional button (e.g. "Retry" or "Add Item").
  final String? actionLabel;

  /// Callback when the user presses the optional action button.
  final VoidCallback? onActionPressed;

  /// Optional semantic identifier for the action button.
  final String? actionSemanticIdentifier;

  /// Builder for the action button widget.
  ///
  /// When provided, this is used instead of a default button implementation.
  /// Receives the [onActionPressed] callback and [actionLabel] text.
  final Widget Function(VoidCallback onPressed, String label)?
      actionButtonBuilder;

  /// Padding around the entire placeholder content.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Optional icon or image
          if (iconData != null) ...[
            Icon(iconData, size: 48, color: context.colors.icon),
            const SizedBox(height: 12),
          ] else if (imageWidget != null) ...[
            imageWidget!,
            const SizedBox(height: 12),
          ],

          // Title
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: context.texts.h4,
          ),

          if (hasSubtitle) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.texts.muted,
            ),
          ],

          // Optional Action
          if (onActionPressed != null && actionLabel != null) ...[
            const SizedBox(height: 24),
            if (actionSemanticIdentifier != null)
              Semantics(
                identifier: actionSemanticIdentifier,
                button: true,
                child: actionButtonBuilder != null
                    ? actionButtonBuilder!(onActionPressed!, actionLabel!)
                    : ElevatedButton(
                        onPressed: onActionPressed,
                        child: Text(actionLabel!),
                      ),
              )
            else
              actionButtonBuilder != null
                  ? actionButtonBuilder!(onActionPressed!, actionLabel!)
                  : ElevatedButton(
                      onPressed: onActionPressed,
                      child: Text(actionLabel!),
                    ),
          ],
        ],
      ),
    );
  }
}
