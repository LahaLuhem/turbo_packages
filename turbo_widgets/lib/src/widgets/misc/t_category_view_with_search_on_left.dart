import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Custom category view with search button on the left, next to category tabs.
/// Used so the search icon appears at top left; when search opens, back button
/// replaces it in the same slot.
class TCategoryViewWithSearchOnLeft extends CategoryView {
  const TCategoryViewWithSearchOnLeft(
    super.config,
    super.state,
    super.tabController,
    super.pageController, {
    super.key,
  });

  @override
  TCategoryViewWithSearchOnLeftState createState() =>
      TCategoryViewWithSearchOnLeftState();
}

class TCategoryViewWithSearchOnLeftState
    extends CategoryViewState<TCategoryViewWithSearchOnLeft> {
  @override
  Widget build(BuildContext context) {
    final tabBarHeight = widget.config.categoryViewConfig.tabBarHeight;

    return Container(
      color: widget.config.categoryViewConfig.backgroundColor,
      child: Row(
        children: [
          SizedBox(
            height: tabBarHeight,
            width: tabBarHeight,
            child: SearchButton(
              widget.config,
              widget.state.onShowSearchView,
              widget.config.categoryViewConfig.iconColor,
            ),
          ),
          Expanded(
            child: DefaultCategoryTabBar(
              widget.config,
              widget.tabController,
              widget.pageController,
              widget.state.categoryEmoji,
              closeSkinToneOverlay,
            ),
          ),
        ],
      ),
    );
  }
}
