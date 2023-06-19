import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/fixed_item_height_delegate.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_bar.dart';

class NavigationTabBarItem {
  NavigationTabBarItem({
    required this.label,
    required this.slivers,
    required this.bottomSlivers,
    this.scrollPosition,
  });

  final String label;

  final List<Widget> slivers;
  final List<Widget> bottomSlivers;
  double? scrollPosition;
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({
    Key? key,
    required this.tabs,
    this.syncWidget,
    this.topSlivers = const [],
    this.currentTab = 0,
    this.navigationHeader,
    this.noContentWidget,
    this.onTabSelected,
    this.onRefresh,
  }) : //assert(tabs.isNotEmpty),
        //assert(currentTab < tabs.length),
        super(key: key);

  final List<NavigationTabBarItem> tabs;
  final Widget? syncWidget;
  final List<Widget> topSlivers;
  final int currentTab;
  final Widget? navigationHeader;
  final Widget? noContentWidget;
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

  double getFixedHeaderHeight() {
    double height = 0;
    if (widget.navigationHeader != null) {
      height += Dimensions.padding16 + Dimensions.padding24;
    }

    if (widget.tabs.isNotEmpty) {
      height += Dimensions.padding26 + Dimensions.navigationTabBarHeight;
    }

    height += Dimensions.padding24;

    return height;
  }

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).viewPadding.top;
    final fixedHeight = topGap + Dimensions.twoLinedBarHeight;

    return Material(
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
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: FixedHeightItemDelegate(
                      child: const SizedBox.shrink(),
                      fixedHeight: topGap + Dimensions.twoLinedBarHeight,
                    ),
                  ),
                  if (widget.syncWidget != null) widget.syncWidget!,
                  if (widget.tabs.isEmpty)
                    widget.noContentWidget!
                  else ...[
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.navigationHeader != null) ...[
                                  Gaps.gap16,
                                  Padding(
                                    padding: Paddings.horizontal16,
                                    child: widget.navigationHeader!,
                                  ),
                                ],
                                if (widget.tabs.isNotEmpty) ...[
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
                        fixedHeight: getFixedHeaderHeight(),
                      ),
                    ),
                    ...widget.tabs[currentTab].slivers,
                    if (widget.tabs[currentTab].bottomSlivers.isNotEmpty ==
                        true)
                      ...widget.tabs[currentTab].bottomSlivers,
                  ],
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: SizedBox.shrink(),
                  ),
                  const SliverGap(Dimensions.padding16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
