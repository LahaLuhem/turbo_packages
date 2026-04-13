import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/widgets/cards/t_card_shell.dart';
import 'package:turbo_widgets/src/widgets/search/t_search_loading_spinner.dart';

class TSearchBar extends StatefulWidget {
  const TSearchBar({
    super.key,
    this.searchTerm = '',
    this.isActive = false,
    this.isLoading = false,
    this.hintText = 'SEARCH WORKSPACE...',
    required this.onChanged,
    this.onBlur,
    this.onClear,
  });

  final String searchTerm;
  final bool isActive;
  final bool isLoading;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onBlur;
  final VoidCallback? onClear;

  @override
  State<TSearchBar> createState() => _TSearchBarState();
}

class _TSearchBarState extends State<TSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: TDurations.sheetAnimation,
    );
    _textController = TextEditingController(text: widget.searchTerm);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant TSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchTerm != oldWidget.searchTerm &&
        widget.searchTerm != _textController.text) {
      _textController.text = widget.searchTerm;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClear() {
    _textController.clear();
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final texts = context.texts;
    final isActiveOrHasTerm = widget.isActive || widget.searchTerm.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, _) {
          final t = _hoverController.value;

          final borderColor = isActiveOrHasTerm
              ? TColors.primaryDark.withValues(alpha: 0.5)
              : Color.lerp(
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.2),
                  t,
                )!;

          final iconColor = isActiveOrHasTerm
              ? colors.primary
              : Color.lerp(
                  TColors.textSecondaryDark,
                  TColors.textPrimaryDark,
                  t,
                )!;

          return SizedBox(
            height: 48,
            child: TCardShell(
              backgroundColor: colors.background,
              borderColor: borderColor,
              boxShadow: isActiveOrHasTerm
                  ? [
                      BoxShadow(
                        color: TColors.primaryDark.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ]
                  : null,
              showBrackets: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: iconColor),
                      duration: TDurations.sheetAnimation,
                      curve: Curves.ease,
                      builder: (context, color, _) => Icon(
                        Icons.search,
                        size: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.escape) {
                            widget.onClear?.call();
                            _focusNode.unfocus();
                          }
                        },
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          onChanged: widget.onChanged,
                          onEditingComplete: () => widget.onBlur?.call(),
                          style: texts.small.copyWith(
                            color: colors.heading,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: widget.hintText,
                            hintStyle: texts.small.copyWith(
                              color: const Color(0xFF52525B),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          autocorrect: false,
                          enableSuggestions: false,
                        ),
                      ),
                    ),
                    if (widget.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: TSearchLoadingSpinner(size: 16),
                      ),
                    if (widget.searchTerm.isNotEmpty && !widget.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: _SearchClearButton(onTap: _handleClear),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchClearButton extends StatefulWidget {
  const _SearchClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SearchClearButton> createState() => _SearchClearButtonState();
}

class _SearchClearButtonState extends State<_SearchClearButton>
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

            final iconColor = Color.lerp(
              const Color(0xFF71717A),
              Colors.white,
              t,
            )!;

            final bgColor = Color.lerp(
              Colors.transparent,
              Colors.white.withValues(alpha: 0.1),
              t,
            )!;

            return Container(
              padding: const EdgeInsets.all(4),
              color: bgColor,
              child: Icon(
                Icons.close,
                size: 16,
                color: iconColor,
              ),
            );
          },
        ),
      ),
    );
  }
}
