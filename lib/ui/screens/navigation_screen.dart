import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_bar.dart';
import 'package:scalesoft_app/ui/widgets/shrinking_auto_blur_header_delegate.dart';

class NavigationBarTabItem {
  NavigationBarTabItem({
    required this.label,
    this.topSlivers = const [],
    required this.slivers,
    this.onRefresh,
    this.scrollPosition,
  });

  final String label;
  final List<Widget> topSlivers;
  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;
  double? scrollPosition;
}

class NavigationScreen extends StatefulWidget {
  NavigationScreen({
    Key? key,
    required this.tabs,
    this.currentTab = 0,
    required this.topHeader,
    required this.navigationHeader,
    required this.topHeaderHeight,
  })  : assert(tabs.isNotEmpty),
        assert(currentTab < tabs.length),
        super(key: key);

  final List<NavigationBarTabItem> tabs;
  final int currentTab;
  final Widget topHeader;
  final Widget? navigationHeader;
  final double topHeaderHeight;

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
                onRefresh: () async =>
                    widget.tabs[currentTab].onRefresh?.call(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: scrollController,
                  slivers: [
                    SliverGap(
                      topGap + Constants.twoLinedBarHeight,
                    ),
                    ...widget.tabs[currentTab].topSlivers,
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: ShrinkingAutoBlurHeaderDelegate(
                        topOffset: topGap + Constants.twoLinedBarHeight,
                        childHeight: Dimensions.padding16 +
                            Constants.navigationTabBarHeight +
                            Dimensions.padding16 +
                            (widget.navigationHeader != null ? 46 : 0),
                        shrinedChildHeight: widget.topHeaderHeight,
                        shrinkingChild: widget.topHeader,
                        child: Column(
                          children: [
                            if (widget.navigationHeader != null) ...[
                              Gaps.gap16,
                              Padding(
                                padding: Paddings.horizontal16,
                                child: widget.navigationHeader!,
                              ),
                            ],
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
                            Gaps.gap16,
                          ],
                        ),
                        blurColor:
                             Theme.of(context).colorScheme.background.withOpacity(0.8),
                      ),
                    ),
                    ...widget.tabs[currentTab].slivers,
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
