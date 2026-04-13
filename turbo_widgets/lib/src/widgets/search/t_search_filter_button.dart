import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/widgets/cards/t_card_shell.dart';

class TSearchFilterButton<F extends Enum> extends StatefulWidget {
  const TSearchFilterButton({
    super.key,
    required this.activeFilterCount,
    required this.filterTypes,
    required this.selectedTypes,
    required this.onToggleType,
    required this.labelBuilder,
  });

  final int activeFilterCount;
  final List<F> filterTypes;
  final Set<F> selectedTypes;
  final ValueChanged<F> onToggleType;
  final String Function(F) labelBuilder;

  @override
  State<TSearchFilterButton<F>> createState() => _TSearchFilterButtonState<F>();
}

class _TSearchFilterButtonState<F extends Enum>
    extends State<TSearchFilterButton<F>> {
  final ShadPopoverController _popoverController = ShadPopoverController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      controller: _popoverController,
      padding: EdgeInsets.zero,
      popover: (popoverContext) => _FilterPopoverContent<F>(
        filterTypes: widget.filterTypes,
        selectedTypes: widget.selectedTypes,
        onToggleType: widget.onToggleType,
        labelBuilder: widget.labelBuilder,
      ),
      child: _FilterTriggerButton(
        activeFilterCount: widget.activeFilterCount,
        onTap: _popoverController.toggle,
      ),
    );
  }
}

class _FilterTriggerButton extends StatefulWidget {
  const _FilterTriggerButton({
    required this.activeFilterCount,
    required this.onTap,
  });

  final int activeFilterCount;
  final VoidCallback onTap;

  @override
  State<_FilterTriggerButton> createState() => _FilterTriggerButtonState();
}

class _FilterTriggerButtonState extends State<_FilterTriggerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: TDurations.sheetAnimation,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = widget.activeFilterCount > 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            final t = _hoverController.value;

            final borderColor = hasActiveFilter
                ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                : Color.lerp(
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.2),
                    t,
                  )!;

            return SizedBox(
              width: 48,
              height: 48,
              child: TCardShell(
                backgroundColor: context.colors.background,
                borderColor: borderColor,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.tune,
                        size: 18,
                        color: Color(0xFFA1A1AA),
                      ),
                    ),
                    if (hasActiveFilter)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: _FilterBadge(count: widget.activeFilterCount),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  const _FilterBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Color(0xFFF59E0B),
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _FilterPopoverContent<F extends Enum> extends StatelessWidget {
  const _FilterPopoverContent({
    required this.filterTypes,
    required this.selectedTypes,
    required this.onToggleType,
    required this.labelBuilder,
  });

  final List<F> filterTypes;
  final Set<F> selectedTypes;
  final ValueChanged<F> onToggleType;
  final String Function(F) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 224,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PopoverHeader(title: 'Filter by Type'),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: filterTypes.map((type) {
                return _PopoverCheckItem(
                  label: labelBuilder(type),
                  isSelected: selectedTypes.contains(type),
                  onTap: () => onToggleType(type),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopoverHeader extends StatelessWidget {
  const _PopoverHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: TColors.textSecondaryDark,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _PopoverCheckItem extends StatefulWidget {
  const _PopoverCheckItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_PopoverCheckItem> createState() => _PopoverCheckItemState();
}

class _PopoverCheckItemState extends State<_PopoverCheckItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: TDurations.hover,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, _) {
            final t = _hoverController.value;

            final textColor = widget.isSelected
                ? colors.heading
                : Color.lerp(
                    TColors.textSecondaryDark,
                    colors.heading,
                    t,
                  )!;

            final bgColor = widget.isSelected || t > 0
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: bgColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  if (widget.isSelected)
                    Icon(
                      Icons.check,
                      size: 14,
                      color: colors.primary,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
