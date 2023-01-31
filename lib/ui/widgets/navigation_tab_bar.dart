import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';

class NavigationTabBar extends StatelessWidget {
  NavigationTabBar({
    Key? key,
    required this.tabs,
    required this.onTabChanged,
    this.currentTab = 0,
  })  : assert(tabs.isNotEmpty),
        assert(currentTab < tabs.length),
        super(key: key);

  final List<NavigationBarTabItem> tabs;
  final int currentTab;
  final Function onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...tabs
              .map(
                (tab) => Row(
                  children: [
                    NavigationTabChip(
                      label: tab.label,
                      isSelected: currentTab == tabs.indexOf(tab),
                      onTap: () {
                        if (currentTab == tabs.indexOf(tab)) {
                          return;
                        }
                        final newCurrentTab = tabs.indexOf(tab);
                        onTabChanged.call(newCurrentTab, currentTab);
                      },
                    ),
                    Gaps.gap8,
                  ],
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
