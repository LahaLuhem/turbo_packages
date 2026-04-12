import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/enums/t_collection_section_layout.dart';

class TCollectionToolbar extends StatelessWidget {
  const TCollectionToolbar({
    required this.searchQuery,
    required this.layout,
    super.key,
    this.onSearchChanged,
    this.searchHint = 'Search',
    this.sortLabel = 'Sort',
    this.sortOptions = const [],
    this.sortValue,
    this.onSortSelected,
    this.filterLabel = 'Filter',
    this.filterOptions = const [],
    this.filterValue,
    this.onFilterSelected,
    this.onLayoutChanged,
    this.spacing = 12.0,
    this.runSpacing = 12.0,
  });

  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final String searchHint;

  final String sortLabel;
  final List<String> sortOptions;
  final String? sortValue;
  final ValueChanged<String>? onSortSelected;

  final String filterLabel;
  final List<String> filterOptions;
  final String? filterValue;
  final ValueChanged<String>? onFilterSelected;

  final TCollectionSectionLayout layout;
  final ValueChanged<TCollectionSectionLayout>? onLayoutChanged;

  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: ShadInput(
            initialValue: searchQuery,
            placeholder: Text(searchHint),
            onChanged: onSearchChanged,
          ),
        ),
        if (sortOptions.isNotEmpty)
          _TCollectionToolbarSelect(
            label: sortLabel,
            options: sortOptions,
            value: sortValue,
            onChanged: onSortSelected,
          ),
        if (filterOptions.isNotEmpty)
          _TCollectionToolbarSelect(
            label: filterLabel,
            options: filterOptions,
            value: filterValue,
            onChanged: onFilterSelected,
          ),
        _TCollectionLayoutToggle(
          layout: layout,
          onLayoutChanged: onLayoutChanged,
        ),
      ],
    );
  }
}

class _TCollectionToolbarSelect extends StatelessWidget {
  const _TCollectionToolbarSelect({
    required this.label,
    required this.options,
    this.value,
    this.onChanged,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ShadSelect<String>(
        placeholder: Text(label),
        initialValue: value ?? (options.isNotEmpty ? options.first : null),
        options: options
            .map(
              (option) => ShadOption(
                value: option,
                child: Text(option),
              ),
            )
            .toList(),
        selectedOptionBuilder: (context, value) => Text(value),
        onChanged: (value) {
          if (value != null) {
            onChanged?.call(value);
          }
        },
      ),
    );
  }
}

class _TCollectionLayoutToggle extends StatelessWidget {
  const _TCollectionLayoutToggle({
    required this.layout,
    this.onLayoutChanged,
  });

  final TCollectionSectionLayout layout;
  final ValueChanged<TCollectionSectionLayout>? onLayoutChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TCollectionLayoutButton(
          isSelected: layout == TCollectionSectionLayout.bento,
          icon: LucideIcons.layoutDashboard,
          onPressed: () =>
              onLayoutChanged?.call(TCollectionSectionLayout.bento),
        ),
        const SizedBox(width: 8),
        _TCollectionLayoutButton(
          isSelected: layout == TCollectionSectionLayout.list,
          icon: LucideIcons.list,
          onPressed: () => onLayoutChanged?.call(TCollectionSectionLayout.list),
        ),
        const SizedBox(width: 8),
        _TCollectionLayoutButton(
          isSelected: layout == TCollectionSectionLayout.grid,
          icon: LucideIcons.layoutGrid,
          onPressed: () => onLayoutChanged?.call(TCollectionSectionLayout.grid),
        ),
      ],
    );
  }
}

class _TCollectionLayoutButton extends StatelessWidget {
  const _TCollectionLayoutButton({
    required this.isSelected,
    required this.icon,
    this.onPressed,
  });

  final bool isSelected;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ShadButton.raw(
      variant: isSelected
          ? ShadButtonVariant.primary
          : ShadButtonVariant.outline,
      size: ShadButtonSize.sm,
      width: 36,
      height: 36,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(icon, size: 16),
    );
  }
}
