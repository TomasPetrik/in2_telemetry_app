import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/fixed_item_height_delegate.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_bar.dart';

class NavigationBarTabItem {
  NavigationBarTabItem({
    required this.label,
    required this.slivers,
    this.scrollPosition,
  });

  final String label;

  final List<Widget> slivers;
  double? scrollPosition;
}

class NavigationScreen extends StatefulWidget {
  NavigationScreen({
    Key? key,
    required this.tabs,
    this.topSlivers = const [],
    this.currentTab = 0,
    required this.topHeader,
    required this.navigationHeader,
    required this.topHeaderHeight,
    this.onTabSelected,
    this.bottomSlivers,
    this.onRefresh,
  })  : assert(tabs.isNotEmpty),
        assert(currentTab < tabs.length),
        super(key: key);

  final List<NavigationBarTabItem> tabs;
  final List<Widget> topSlivers;
  final int currentTab;
  final Widget topHeader;
  final Widget? navigationHeader;
  final double topHeaderHeight;
  final List<Widget>? bottomSlivers;
  final Function(int tabIndex)? onTabSelected;

  final Future<void> Function()? onRefresh;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int currentTab = 0;

  final scrollController = ScrollController();

  double? offset;

  @override
  void initState() {
    currentTab = widget.currentTab;

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void onTabTap(int newTabIndex, int prevTabIndex) {
    widget.onTabSelected?.call(newTabIndex);
    setState(() => currentTab = newTabIndex);

    widget.tabs[prevTabIndex].scrollPosition = scrollController.position.pixels;

    if (widget.tabs[currentTab].scrollPosition != null) {
      scrollController.jumpTo(widget.tabs[currentTab].scrollPosition!);
    } else {
      scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).viewPadding.top;
    final fixedHeight = topGap + Constants.twoLinedBarHeight;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Material(
        child: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                edgeOffset: fixedHeight,
                color: Theme.of(context).hintColor,
                backgroundColor: Theme.of(context).colorScheme.background,
                onRefresh: () async => widget.onRefresh?.call(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: scrollController,
                  slivers: [
                    /*
                    SliverGap(
                      topGap + Constants.twoLinedBarHeight,
                    ),
                    */
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: FixedHeightItemDelegate(
                        child: const SizedBox.shrink(),
                        fixedHeight: topGap + Constants.twoLinedBarHeight,
                      ),
                    ),
                    ...widget.topSlivers,
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: FixedHeightItemDelegate(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                if (widget.navigationHeader != null) ...[
                                  Gaps.gap16,
                                  Padding(
                                    padding: Paddings.horizontal16,
                                    child: widget.navigationHeader!,
                                  ),
                                ],
                                if (widget.tabs.length > 1) ...[
                                  Gaps.gap26,
                                  Padding(
                                    padding: Paddings.horizontal16,
                                    child: NavigationTabBar(
                                      tabs: widget.tabs,
                                      onTabChanged: (
                                        int newTabIndex,
                                        int previousTabIndex,
                                      ) {
                                        onTabTap(
                                          newTabIndex,
                                          previousTabIndex,
                                        );
                                      },
                                      currentTab: currentTab,
                                    ),
                                  ),
                                ],
                                Gaps.gap24,
                              ],
                            ),
                          ],
                        ),
                        fixedHeight: Dimensions.padding16 +
                            (widget.tabs.length > 1
                                ? Dimensions.padding26 +
                                    Constants.navigationTabBarHeight
                                : 0) +
                            Dimensions.padding24 +
                            Dimensions.padding20,
                      ),
                    ),
                    ...widget.tabs[currentTab].slivers,
                    if (widget.bottomSlivers?.isNotEmpty == true)
                      ...widget.bottomSlivers!,
                    const SliverFillRemaining(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
