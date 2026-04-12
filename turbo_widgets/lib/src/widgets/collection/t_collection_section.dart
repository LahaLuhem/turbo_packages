import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/enums/t_bento_grid_animation.dart';
import 'package:turbo_widgets/src/enums/t_collection_section_layout.dart';
import 'package:turbo_widgets/src/models/layout/t_bento_item.dart';
import 'package:turbo_widgets/src/widgets/layout/t_bento_grid.dart';

class TCollectionSection extends StatelessWidget {
  const TCollectionSection({
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.caption,
    this.trailing,
    this.layout = TCollectionSectionLayout.bento,
    this.sectionSpacing = 12.0,
    this.itemSpacing = 12.0,
    this.itemSizeBuilder,
    this.bentoHeight = 320,
    this.bentoAnimation = TBentoGridAnimation.fade,
    this.gridCrossAxisCount = 2,
    this.gridMainAxisSpacing = 12.0,
    this.gridCrossAxisSpacing = 12.0,
    this.gridChildAspectRatio = 1.0,
    this.gridMainAxisExtent,
  }) : assert(
         gridCrossAxisCount > 0,
         'gridCrossAxisCount must be greater than 0.',
       );

  final String title;
  final String? caption;
  final Widget? trailing;
  final TCollectionSectionLayout layout;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double sectionSpacing;
  final double itemSpacing;
  final double Function(int index)? itemSizeBuilder;
  final double bentoHeight;
  final TBentoGridAnimation bentoAnimation;
  final int gridCrossAxisCount;
  final double gridMainAxisSpacing;
  final double gridCrossAxisSpacing;
  final double gridChildAspectRatio;
  final double? gridMainAxisExtent;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      itemCount,
      (index) => itemBuilder(context, index),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TCollectionSectionHeader(
          title: title,
          caption: caption,
          trailing: trailing,
        ),
        SizedBox(height: sectionSpacing),
        if (items.isNotEmpty)
          _TCollectionSectionBody(
            items: items,
            layout: layout,
            itemSpacing: itemSpacing,
            itemSizeBuilder: itemSizeBuilder,
            bentoHeight: bentoHeight,
            bentoAnimation: bentoAnimation,
            gridCrossAxisCount: gridCrossAxisCount,
            gridCrossAxisSpacing: gridCrossAxisSpacing,
            gridMainAxisSpacing: gridMainAxisSpacing,
            gridChildAspectRatio: gridChildAspectRatio,
            gridMainAxisExtent: gridMainAxisExtent,
          ),
      ],
    );
  }
}

class _TCollectionSectionHeader extends StatelessWidget {
  const _TCollectionSectionHeader({
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

class _TCollectionSectionBody extends StatelessWidget {
  const _TCollectionSectionBody({
    required this.items,
    required this.layout,
    required this.itemSpacing,
    required this.bentoHeight,
    required this.bentoAnimation,
    required this.gridCrossAxisCount,
    required this.gridCrossAxisSpacing,
    required this.gridMainAxisSpacing,
    required this.gridChildAspectRatio,
    this.itemSizeBuilder,
    this.gridMainAxisExtent,
  });

  final List<Widget> items;
  final TCollectionSectionLayout layout;
  final double itemSpacing;
  final double Function(int index)? itemSizeBuilder;
  final double bentoHeight;
  final TBentoGridAnimation bentoAnimation;
  final int gridCrossAxisCount;
  final double gridMainAxisSpacing;
  final double gridCrossAxisSpacing;
  final double gridChildAspectRatio;
  final double? gridMainAxisExtent;

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      TCollectionSectionLayout.bento => _TCollectionBentoGrid(
        items: items,
        itemSpacing: itemSpacing,
        itemSizeBuilder: itemSizeBuilder,
        height: bentoHeight,
        animation: bentoAnimation,
      ),
      TCollectionSectionLayout.list => _TCollectionList(
        items: items,
        spacing: itemSpacing,
      ),
      TCollectionSectionLayout.grid => _TCollectionGrid(
        items: items,
        crossAxisCount: gridCrossAxisCount,
        crossAxisSpacing: gridCrossAxisSpacing,
        mainAxisSpacing: gridMainAxisSpacing,
        childAspectRatio: gridChildAspectRatio,
        mainAxisExtent: gridMainAxisExtent,
      ),
    };
  }
}

class _TCollectionBentoGrid extends StatelessWidget {
  const _TCollectionBentoGrid({
    required this.items,
    required this.itemSpacing,
    required this.height,
    required this.animation,
    this.itemSizeBuilder,
  });

  final List<Widget> items;
  final double itemSpacing;
  final double height;
  final TBentoGridAnimation animation;
  final double Function(int index)? itemSizeBuilder;

  @override
  Widget build(BuildContext context) {
    final bentoItems = <TBentoItem>[
      for (int i = 0; i < items.length; i++)
        TBentoItem(
          size: itemSizeBuilder?.call(i) ?? 1.0,
          child: items[i],
        ),
    ];

    return SizedBox(
      height: height,
      child: TBentoGrid(
        items: bentoItems,
        spacing: itemSpacing,
        animation: animation,
      ),
    );
  }
}

class _TCollectionList extends StatelessWidget {
  const _TCollectionList({
    required this.items,
    required this.spacing,
  });

  final List<Widget> items;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < items.length; index++) ...[
          if (index > 0) SizedBox(height: spacing),
          items[index],
        ],
      ],
    );
  }
}

class _TCollectionGrid extends StatelessWidget {
  const _TCollectionGrid({
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
