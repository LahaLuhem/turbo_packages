import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Custom search view for emoji picker with search bar at top and grid results below.
/// Replaces DefaultSearchView to fix layout: search bar fixed at top, results in grid.
class TEmojiSearchView extends SearchView {
  const TEmojiSearchView(
    super.config,
    super.state,
    super.showEmojiView, {
    super.key,
  });

  @override
  TEmojiSearchViewState createState() => TEmojiSearchViewState();
}

class TEmojiSearchViewState extends SearchViewState<TEmojiSearchView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final emojiSize = widget.config.emojiViewConfig.getEmojiSize(
            constraints.maxWidth,
          );
          final emojiBoxSize = widget.config.emojiViewConfig.getEmojiBoxSize(
            constraints.maxWidth,
          );
          final evConfig = widget.config.emojiViewConfig;
          final svConfig = widget.config.searchViewConfig;
          final dividerColor = widget.config.categoryViewConfig.dividerColor;

          return Container(
            color: svConfig.backgroundColor,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: widget.config.categoryViewConfig.tabBarHeight,
                      width: widget.config.categoryViewConfig.tabBarHeight,
                      child: IconButton(
                        onPressed: widget.showEmojiView,
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        color: svConfig.buttonIconColor,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: onTextInputChanged,
                        focusNode: focusNode,
                        style: svConfig.inputTextStyle,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: svConfig.hintText,
                          hintStyle: svConfig.hintTextStyle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(height: 1, color: dividerColor),
                Expanded(
                  child: results.isEmpty
                      ? Center(
                          child: Text(
                            'No results',
                            style:
                                svConfig.hintTextStyle ??
                                TextStyle(color: svConfig.buttonIconColor),
                          ),
                        )
                      : GridView.builder(
                          padding: evConfig.gridPadding,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: evConfig.columns,
                                childAspectRatio: 1,
                                mainAxisSpacing: evConfig.verticalSpacing,
                                crossAxisSpacing: evConfig.horizontalSpacing,
                              ),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            return buildEmoji(
                              results[index],
                              emojiSize,
                              emojiBoxSize,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
