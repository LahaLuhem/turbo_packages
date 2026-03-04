import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/models/navigation/t_button_config.dart';

enum TSideNavBarLayout {
  auto,
  vertical,
  horizontal,
}

enum TSideNavBarButtonAlignment {
  start,
  center,
  end,
  spaceBetween,
  spaceEvenly,
  spaceAround,
}

typedef TSideNavBarItemBuilder =
    Widget Function(
      BuildContext context,
      TButtonConfig config,
      bool isActive,
      VoidCallback onTap,
    );

class TSideNavBar extends StatelessWidget {
  const TSideNavBar({
    required this.buttons,
    super.key,
    this.layout = TSideNavBarLayout.auto,
    this.buttonAlignment = TSideNavBarButtonAlignment.start,
    this.isExpanded = false,
    this.selectedKey,
    this.onSelect,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.spacing = 4,
    this.collapsedWidth = 56,
    this.expandedWidth = 200,
    this.horizontalBreakpoint = 500,
    this.iconSize = 20,
    this.activeIconRadius = 12,
    this.labelFontSize = 10,
    this.backgroundColor,
    this.showDividers = false,
    this.itemBuilder,
  });

  final Map<String, TButtonConfig> buttons;
  final TSideNavBarLayout layout;
  final TSideNavBarButtonAlignment buttonAlignment;
  final bool isExpanded;
  final String? selectedKey;
  final ValueChanged<String>? onSelect;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets padding;
  final double spacing;
  final double collapsedWidth;
  final double expandedWidth;
  final double horizontalBreakpoint;
  final double iconSize;
  final double activeIconRadius;
  final double labelFontSize;
  final Color? backgroundColor;
  final bool showDividers;
  final TSideNavBarItemBuilder? itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty && leading == null && trailing == null) {
      return const SizedBox.shrink();
    }

    if (layout != TSideNavBarLayout.auto) {
      return _buildForLayout(layout == TSideNavBarLayout.vertical);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxWidth > horizontalBreakpoint;
        return _buildForLayout(isVertical);
      },
    );
  }

  Widget _buildForLayout(bool isVertical) {
    if (isVertical) {
      return _TSideNavBarVertical(
        buttons: buttons,
        buttonAlignment: buttonAlignment,
        isExpanded: isExpanded,
        selectedKey: selectedKey,
        onSelect: onSelect,
        leading: leading,
        trailing: trailing,
        padding: padding,
        spacing: spacing,
        collapsedWidth: collapsedWidth,
        expandedWidth: expandedWidth,
        iconSize: iconSize,
        activeIconRadius: activeIconRadius,
        labelFontSize: labelFontSize,
        backgroundColor: backgroundColor,
        showDividers: showDividers,
        itemBuilder: itemBuilder,
      );
    }

    return _TSideNavBarHorizontal(
      buttons: buttons,
      selectedKey: selectedKey,
      onSelect: onSelect,
      leading: leading,
      trailing: trailing,
      padding: padding,
      spacing: spacing,
      iconSize: iconSize,
      activeIconRadius: activeIconRadius,
      labelFontSize: labelFontSize,
      backgroundColor: backgroundColor,
      itemBuilder: itemBuilder,
    );
  }
}

// ---------------------------------------------------------------------------
// Vertical side rail
// ---------------------------------------------------------------------------

class _TSideNavBarVertical extends StatelessWidget {
  const _TSideNavBarVertical({
    required this.buttons,
    required this.buttonAlignment,
    required this.isExpanded,
    required this.selectedKey,
    required this.onSelect,
    required this.leading,
    required this.trailing,
    required this.padding,
    required this.spacing,
    required this.collapsedWidth,
    required this.expandedWidth,
    required this.iconSize,
    required this.activeIconRadius,
    required this.labelFontSize,
    required this.backgroundColor,
    required this.showDividers,
    required this.itemBuilder,
  });

  final Map<String, TButtonConfig> buttons;
  final TSideNavBarButtonAlignment buttonAlignment;
  final bool isExpanded;
  final String? selectedKey;
  final ValueChanged<String>? onSelect;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets padding;
  final double spacing;
  final double collapsedWidth;
  final double expandedWidth;
  final double iconSize;
  final double activeIconRadius;
  final double labelFontSize;
  final Color? backgroundColor;
  final bool showDividers;
  final TSideNavBarItemBuilder? itemBuilder;

  MainAxisAlignment get _mainAxisAlignment => switch (buttonAlignment) {
    TSideNavBarButtonAlignment.start => MainAxisAlignment.start,
    TSideNavBarButtonAlignment.center => MainAxisAlignment.center,
    TSideNavBarButtonAlignment.end => MainAxisAlignment.end,
    TSideNavBarButtonAlignment.spaceBetween => MainAxisAlignment.spaceBetween,
    TSideNavBarButtonAlignment.spaceEvenly => MainAxisAlignment.spaceEvenly,
    TSideNavBarButtonAlignment.spaceAround => MainAxisAlignment.spaceAround,
  };

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.background;
    final dividerColor = theme.colorScheme.border;
    final width = isExpanded ? expandedWidth : collapsedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      color: bgColor,
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            if (leading != null) ...[
              leading!,
              if (showDividers)
                Divider(height: spacing * 2, color: dividerColor)
              else
                SizedBox(height: spacing * 2),
            ],
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: _mainAxisAlignment,
                  mainAxisSize: MainAxisSize.min,
                  children: _buildButtons(theme),
                ),
              ),
            ),
            if (trailing != null) ...[
              if (showDividers)
                Divider(height: spacing * 2, color: dividerColor)
              else
                SizedBox(height: spacing * 2),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildButtons(ShadThemeData theme) {
    final entries = buttons.entries.toList();
    final children = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isActive = entry.key == selectedKey;
      final onTap = () {
        entry.value.onPressed();
        onSelect?.call(entry.key);
      };

      if (itemBuilder != null) {
        children.add(
          Builder(
            builder: (context) =>
                itemBuilder!(context, entry.value, isActive, onTap),
          ),
        );
      } else if (isExpanded) {
        children.add(
          _TSideNavBarExpandedItem(
            config: entry.value,
            isActive: isActive,
            iconSize: iconSize,
            activeIconRadius: activeIconRadius,
            labelFontSize: labelFontSize,
            onTap: onTap,
          ),
        );
      } else {
        children.add(
          _TSideNavBarCollapsedItem(
            config: entry.value,
            isActive: isActive,
            iconSize: iconSize,
            activeIconRadius: activeIconRadius,
            labelFontSize: labelFontSize,
            onTap: onTap,
          ),
        );
      }

      if (i < entries.length - 1) {
        children.add(SizedBox(height: spacing));
      }
    }
    return children;
  }
}

// ---------------------------------------------------------------------------
// Horizontal bottom bar
// ---------------------------------------------------------------------------

class _TSideNavBarHorizontal extends StatelessWidget {
  const _TSideNavBarHorizontal({
    required this.buttons,
    required this.selectedKey,
    required this.onSelect,
    required this.leading,
    required this.trailing,
    required this.padding,
    required this.spacing,
    required this.iconSize,
    required this.activeIconRadius,
    required this.labelFontSize,
    required this.backgroundColor,
    required this.itemBuilder,
  });

  final Map<String, TButtonConfig> buttons;
  final String? selectedKey;
  final ValueChanged<String>? onSelect;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets padding;
  final double spacing;
  final double iconSize;
  final double activeIconRadius;
  final double labelFontSize;
  final Color? backgroundColor;
  final TSideNavBarItemBuilder? itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.background;

    return Container(
      color: bgColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: spacing),
              ],
              ..._buildButtons(),
              if (trailing != null) ...[
                SizedBox(width: spacing),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildButtons() {
    final entries = buttons.entries.toList();
    final children = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isActive = entry.key == selectedKey;
      final onTap = () {
        entry.value.onPressed();
        onSelect?.call(entry.key);
      };

      final Widget item;
      if (itemBuilder != null) {
        item = Builder(
          builder: (context) =>
              itemBuilder!(context, entry.value, isActive, onTap),
        );
      } else {
        item = _TSideNavBarCollapsedItem(
          config: entry.value,
          isActive: isActive,
          iconSize: iconSize,
          activeIconRadius: activeIconRadius,
          labelFontSize: labelFontSize,
          onTap: onTap,
        );
      }

      children.add(Expanded(child: item));
    }
    return children;
  }
}

// ---------------------------------------------------------------------------
// Collapsed item: icon above small label (used in both vertical & horizontal)
// ---------------------------------------------------------------------------

class _TSideNavBarCollapsedItem extends StatefulWidget {
  const _TSideNavBarCollapsedItem({
    required this.config,
    required this.isActive,
    required this.iconSize,
    required this.activeIconRadius,
    required this.labelFontSize,
    required this.onTap,
  });

  final TButtonConfig config;
  final bool isActive;
  final double iconSize;
  final double activeIconRadius;
  final double labelFontSize;
  final VoidCallback onTap;

  @override
  State<_TSideNavBarCollapsedItem> createState() =>
      _TSideNavBarCollapsedItemState();
}

class _TSideNavBarCollapsedItemState extends State<_TSideNavBarCollapsedItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final activeColor = theme.colorScheme.foreground;
    final inactiveColor = theme.colorScheme.mutedForeground.withValues(
      alpha: 0.5,
    );
    final color = widget.isActive ? activeColor : inactiveColor;
    final containerSize = widget.iconSize + 16;

    final Color bgColor;
    if (widget.isActive) {
      bgColor = theme.colorScheme.foreground.withValues(alpha: 0.1);
    } else if (_isHovered) {
      bgColor = theme.colorScheme.foreground.withValues(alpha: 0.05);
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(widget.activeIconRadius),
              ),
              child: Center(
                child: widget.config.icon != null
                    ? Icon(
                        widget.config.icon,
                        size: widget.iconSize,
                        color: color,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            if (widget.config.label != null) ...[
              const SizedBox(height: 2),
              SizedBox(
                width: containerSize + 8,
                child: Text(
                  widget.config.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.labelFontSize,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: color,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expanded item: icon left of label in a row (used in vertical expanded mode)
// ---------------------------------------------------------------------------

class _TSideNavBarExpandedItem extends StatefulWidget {
  const _TSideNavBarExpandedItem({
    required this.config,
    required this.isActive,
    required this.iconSize,
    required this.activeIconRadius,
    required this.labelFontSize,
    required this.onTap,
  });

  final TButtonConfig config;
  final bool isActive;
  final double iconSize;
  final double activeIconRadius;
  final double labelFontSize;
  final VoidCallback onTap;

  @override
  State<_TSideNavBarExpandedItem> createState() =>
      _TSideNavBarExpandedItemState();
}

class _TSideNavBarExpandedItemState extends State<_TSideNavBarExpandedItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final activeColor = theme.colorScheme.foreground;
    final inactiveColor = theme.colorScheme.mutedForeground.withValues(
      alpha: 0.5,
    );
    final color = widget.isActive ? activeColor : inactiveColor;

    final Color bgColor;
    if (widget.isActive) {
      bgColor = theme.colorScheme.foreground.withValues(alpha: 0.08);
    } else if (_isHovered) {
      bgColor = theme.colorScheme.foreground.withValues(alpha: 0.05);
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.activeIconRadius),
          ),
          child: Row(
            children: [
              if (widget.config.icon != null) ...[
                Icon(widget.config.icon, size: widget.iconSize, color: color),
                const SizedBox(width: 12),
              ],
              if (widget.config.label != null)
                Expanded(
                  child: Text(
                    widget.config.label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.labelFontSize + 3,
                      fontWeight: widget.isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: color,
                      height: 1.2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
