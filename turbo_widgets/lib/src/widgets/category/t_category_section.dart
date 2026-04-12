import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/enums/t_category_section_layout.dart';
import 'package:turbo_widgets/src/widgets/category/t_category_card.dart';

class TCategorySection extends StatefulWidget {
  const TCategorySection({
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.caption,
    this.trailing,
    this.layout = TCategorySectionLayout.horizontal,
    this.maxLines = 2,
    this.maxItems,
    this.onShowAll,
    this.showAllLabel = 'Show all',
    this.showAllIcon = LucideIcons.arrowRight,
    this.itemSpacing = 12.0,
    this.headerSpacing = 12.0,
    this.gridCrossAxisCount = 2,
    this.gridMainAxisSpacing = 12.0,
    this.gridCrossAxisSpacing = 12.0,
    this.gridChildAspectRatio = 1.0,
    this.gridMainAxisExtent,
  }) : assert(maxLines > 0, 'maxLines must be greater than 0.'),
       assert(
         gridCrossAxisCount > 0,
         'gridCrossAxisCount must be greater than 0.',
       );

  final String title;
  final String? caption;
  final Widget? trailing;
  final TCategorySectionLayout layout;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int maxLines;
  final int? maxItems;
  final VoidCallback? onShowAll;
  final String showAllLabel;
  final IconData showAllIcon;
  final double itemSpacing;
  final double headerSpacing;
  final int gridCrossAxisCount;
  final double gridMainAxisSpacing;
  final double gridCrossAxisSpacing;
  final double gridChildAspectRatio;
  final double? gridMainAxisExtent;

  @override
  State<TCategorySection> createState() => _TCategorySectionState();
}

class _TCategorySectionState extends State<TCategorySection> {
  bool _isExpanded = false;

  void _handleShowAll() {
    if (widget.onShowAll != null) {
      widget.onShowAll!();
    } else {
      setState(() {
        _isExpanded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canExpand = widget.onShowAll == null;
    final maxItems = widget.maxItems;
    final isLimited = maxItems != null && widget.itemCount > maxItems;
    final isExpanded = canExpand && _isExpanded;
    final shouldShowAllAction = isLimited && !isExpanded;
    final visibleCount = isLimited && !isExpanded
        ? min(maxItems, widget.itemCount)
        : widget.itemCount;

    final items = <Widget>[
      for (int index = 0; index < visibleCount; index++)
        widget.itemBuilder(context, index),
      if (shouldShowAllAction)
        TCategoryCard(
          title: widget.showAllLabel,
          icon: widget.showAllIcon,
          onPressed: _handleShowAll,
        ),
    ];

    final trailingActions = <Widget>[
      if (widget.trailing != null) widget.trailing!,
      if (shouldShowAllAction)
        ShadButton.outline(
          size: ShadButtonSize.sm,
          onPressed: _handleShowAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.showAllLabel),
              const SizedBox(width: 6),
              Icon(widget.showAllIcon, size: 16),
            ],
          ),
        ),
    ];

    final Widget content = widget.layout == TCategorySectionLayout.horizontal
        ? _TCategoryHorizontalList(
            items: items,
            maxLines: widget.maxLines,
            spacing: widget.itemSpacing,
          )
        : _TCategoryGridList(
            items: items,
            crossAxisCount: widget.gridCrossAxisCount,
            crossAxisSpacing: widget.gridCrossAxisSpacing,
            mainAxisSpacing: widget.gridMainAxisSpacing,
            childAspectRatio: widget.gridChildAspectRatio,
            mainAxisExtent: widget.gridMainAxisExtent,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TCategorySectionHeader(
          title: widget.title,
          caption: widget.caption,
          trailing: trailingActions.isEmpty
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int index = 0; index < trailingActions.length; index++)
                      Padding(
                        padding: EdgeInsets.only(left: index == 0 ? 0 : 8.0),
                        child: trailingActions[index],
                      ),
                  ],
                ),
        ),
        SizedBox(height: widget.headerSpacing),
        if (items.isNotEmpty) content,
      ],
    );
  }
}

class _TCategorySectionHeader extends StatelessWidget {
  const _TCategorySectionHeader({
    required this.title,
    this.caption,
    this.trailing,
  });

  final String title;
  final String? caption;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(
                  caption!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.muted,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _TCategoryHorizontalList extends StatelessWidget {
  const _TCategoryHorizontalList({
    required this.items,
    required this.maxLines,
    required this.spacing,
  });

  final List<Widget> items;
  final int maxLines;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final columns = <Widget>[];
    for (int i = 0; i < items.length; i += maxLines) {
      final end = min(i + maxLines, items.length);
      final columnItems = items.sublist(i, end);
      columns.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int index = 0; index < columnItems.length; index++) ...[
              if (index > 0) SizedBox(height: spacing),
              columnItems[index],
            ],
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int index = 0; index < columns.length; index++) ...[
            if (index > 0) SizedBox(width: spacing),
            columns[index],
          ],
        ],
      ),
    );
  }
}

class _TCategoryGridList extends StatelessWidget {
  const _TCategoryGridList({
    required this.items,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.childAspectRatio,
    this.mainAxisExtent,
  });

  final List<Widget> items;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: mainAxisExtent,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}
