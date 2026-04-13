import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'
    hide Category, Emoji;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as epf;
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/widgets/misc/t_category_view_with_search_on_left.dart';
import 'package:turbo_widgets/src/widgets/misc/t_emoji_search_view.dart';

class TEmojiPickerPopover extends StatefulWidget {
  const TEmojiPickerPopover({
    super.key,
    this.selectedEmoji,
    required this.onEmojiSelected,
    required this.child,
  });

  final String? selectedEmoji;
  final ValueChanged<String> onEmojiSelected;
  final Widget child;

  @override
  State<TEmojiPickerPopover> createState() => _TEmojiPickerPopoverState();
}

class _TEmojiPickerPopoverState extends State<TEmojiPickerPopover> {
  final ShadPopoverController _controller = ShadPopoverController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ShadPopover(
      controller: _controller,
      padding: EdgeInsets.zero,
      popover: (popoverContext) => Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: 350,
          height: 300,
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              widget.onEmojiSelected(emoji.emoji);
              _controller.hide();
            },
            config: Config(
              height: 300,
              checkPlatformCompatibility: false,
              emojiViewConfig: EmojiViewConfig(
                columns: 8,
                emojiSizeMax: 28,
                backgroundColor: colors.card,
                buttonMode: ButtonMode.NONE,
              ),
              categoryViewConfig: CategoryViewConfig(
                backgroundColor: colors.card,
                indicatorColor: colors.primary,
                iconColorSelected: colors.primary,
                iconColor: TColors.textSecondaryDark,
                dividerColor: colors.border,
                initCategory: epf.Category.SMILEYS,
                recentTabBehavior: RecentTabBehavior.NONE,
                extraTab: CategoryExtraTab.SEARCH,
                customCategoryView:
                    (config, state, tabController, pageController) {
                      return TCategoryViewWithSearchOnLeft(
                        config,
                        state,
                        tabController,
                        pageController,
                      );
                    },
              ),
              searchViewConfig: SearchViewConfig(
                backgroundColor: colors.card,
                buttonIconColor: TColors.textSecondaryDark,
                customSearchView: (config, state, showEmojiView) {
                  return TEmojiSearchView(config, state, showEmojiView);
                },
              ),
              bottomActionBarConfig: const BottomActionBarConfig(
                enabled: false,
                showBackspaceButton: false,
                showSearchViewButton: true,
                backgroundColor: Colors.transparent,
                buttonColor: Colors.transparent,
                buttonIconColor: TColors.textSecondaryDark,
              ),
              skinToneConfig: const SkinToneConfig(
                enabled: true,
              ),
            ),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: _controller.toggle,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      ),
    );
  }
}
