import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/screens/configuration_screen.dart';
import 'package:scalesoft_app/ui/screens/dashboard_page.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/tab_icon_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.userAccount,
  }) : super(key: key);

  final UserAccount userAccount;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      DashboardPage(userAccount: widget.userAccount),
      DashboardPage(userAccount: widget.userAccount),
      const ConfigurationScreen(),
    ];
    return Scaffold(
      body: Center(
        child: pages.elementAt(_selectedIndex), //New
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        selectedLabelStyle: ScaleTextStyles.label.apply(color: Theme.of(context).colorScheme.onPrimary),
        unselectedLabelStyle: ScaleTextStyles.label.apply(color: Theme.of(context).colorScheme.onPrimary),
        fixedColor: Theme.of(context).colorScheme.onPrimary,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_wave_pulse.svg',
                color: Theme.of(context).hintColor,
              ),
              isActive: false,
            ),
            activeIcon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_wave_pulse.svg',
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              isActive: true,
            ),
            label: context.locale.tabs_measurement,
          ),
          BottomNavigationBarItem(
            icon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_chart_pie_simple.svg',
                color: Theme.of(context).hintColor,
              ),
              isActive: false,
            ),
            activeIcon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_chart_pie_simple.svg',
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              isActive: true,
            ),
            label: context.locale.tabs_results,
          ),
          BottomNavigationBarItem(
            icon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_dots_horizontal.svg',
                color: Theme.of(context).hintColor,
              ),
              isActive: false,
            ),
            activeIcon: TabIconWidget(
              icon: SvgPicture.asset(
                'assets/icons/icon_dots_horizontal.svg',
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              isActive: true,
            ),
            label: context.locale.tabs_more,
          ),
        ],
      ),
    );
  }
}
