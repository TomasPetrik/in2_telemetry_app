import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';
import 'package:scalesoft_app/ui/screens/configuration_screen.dart';
import 'package:scalesoft_app/ui/screens/dashboard_screen.dart';
import 'package:scalesoft_app/ui/widgets/tab_icon_widget.dart';
import 'package:scalesoft_app/ui/widgets/user_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
    required this.userInfo,
  }) : super(key: key);

  static const routeName = '/home';

  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Theme.of(context).canvasColor,
        inactiveColor: Theme.of(context).canvasColor,
        backgroundColor: Theme.of(context).backgroundColor,
        height: 70,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_measurement.svg',
                color: Theme.of(context).hintColor,
              ),
              isActive: false,
            ),
            activeIcon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_measurement.svg',
                color: Theme.of(context).primaryColor,
              ),
              isActive: true,
            ),
          ),
          BottomNavigationBarItem(
            icon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_pie_chart.svg',
                color: Theme.of(context).hintColor,
              ),
              isActive: false,
            ),
            activeIcon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_pie_chart.svg',
                color: Theme.of(context).primaryColor,
              ),
              isActive: true,
            ),
          ),
          BottomNavigationBarItem(
            icon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_more_horiz.svg',
                color: Theme.of(context).hintColor,
              ),
              isActive: false,
            ),
            activeIcon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_more_horiz.svg',
                color: Theme.of(context).primaryColor,
              ),
              isActive: true,
            ),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return Positioned.fill(
          child: CupertinoTabView(
            builder: (context) {
              switch (index) {
                case 0:
                  return DashboardPage(userInfo: userInfo);
                case 1:
                  return DashboardPage(userInfo: userInfo);
                case 2:
                default:
                  return const ConfigurationScreen();
              }
            },
          ),
        );
      },
    );
  }
}
