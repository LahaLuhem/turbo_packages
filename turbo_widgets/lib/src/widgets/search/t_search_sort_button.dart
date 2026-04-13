import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/widgets/cards/t_card_shell.dart';

class TSearchSortButton<S extends Enum> extends StatefulWidget {
  const TSearchSortButton({
    super.key,
    required this.sortTypes,
    required this.selectedSort,
    required this.onSortChanged,
    required this.labelBuilder,
  });

  final List<S> sortTypes;
  final S selectedSort;
  final ValueChanged<S> onSortChanged;
  final String Function(S) labelBuilder;

  @override
  State<TSearchSortButton<S>> createState() => _TSearchSortButtonState<S>();
}

class _TSearchSortButtonState<S extends Enum>
    extends State<TSearchSortButton<S>> {
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
      popover: (popoverContext) => _SortPopoverContent<S>(
        sortTypes: widget.sortTypes,
        selectedSort: widget.selectedSort,
        onSortChanged: widget.onSortChanged,
        labelBuilder: widget.labelBuilder,
      ),
      child: _SortTriggerButton(
        onTap: _popoverController.toggle,
      ),
    );
  }
}

class _SortTriggerButton extends StatefulWidget {
  const _SortTriggerButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SortTriggerButton> createState() => _SortTriggerButtonState();
}

class _SortTriggerButtonState extends State<_SortTriggerButton>
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

            final borderColor = Color.lerp(
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
                child: const Center(
                  child: Icon(
                    Icons.swap_vert,
                    size: 18,
                    color: Color(0xFFA1A1AA),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SortPopoverContent<S extends Enum> extends StatelessWidget {
  const _SortPopoverContent({
    required this.sortTypes,
    required this.selectedSort,
    required this.onSortChanged,
    required this.labelBuilder,
  });

  final List<S> sortTypes;
  final S selectedSort;
  final ValueChanged<S> onSortChanged;
  final String Function(S) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 224,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SortPopoverHeader(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sortTypes.map((type) {
                return _SortCheckItem(
                  label: labelBuilder(type),
                  isSelected: selectedSort == type,
                  onTap: () => onSortChanged(type),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortPopoverHeader extends StatelessWidget {
  const _SortPopoverHeader();

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
      child: const Text(
        'SORT RESULTS',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: TColors.textSecondaryDark,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SortCheckItem extends StatefulWidget {
  const _SortCheckItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SortCheckItem> createState() => _SortCheckItemState();
}

class _SortCheckItemState extends State<_SortCheckItem>
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
