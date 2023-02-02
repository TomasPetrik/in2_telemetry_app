import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/warning/warning_bloc.dart';
import 'package:scalesoft_app/bloc/warning/warning_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/dashboard_route.dart';
import 'package:scalesoft_app/ui/routers/routes/results_route.dart';
import 'package:scalesoft_app/ui/routers/routes/configuration_route.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/tab_icon_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
    required this.child,
    required this.path,
  }) : super(key: key);

  final Widget child;
  final String path;

  int _getCurrentTabIndex() {
    if (path.contains(DashboardRoute.name)) {
      return 0;
    } else if (path.contains(ResultsRoute.name)) {
      return 1;
    } else if (path.contains(ConfigurationRoute.name)) {
      return 2;
    } else {
      return 0;
    }
  }

  String _getPathByIndex(int index) {
    switch (index) {
      case 0:
        return DashboardRoute.name;
      case 1:
        return ResultsRoute.name;
      case 2:
        return ConfigurationRoute.name;
      default:
        return DashboardRoute.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: child,
      ),
      bottomNavigationBar: BlocBuilder<WarningBloc, WarningBlocState>(
        bloc: getIt<WarningBloc>(),
        builder: (context, state) {
          final accountDbProvider = getIt<AccountDbProvider>();
          final showWarning = accountDbProvider.getAll().any(
                (userAccount) => userAccount.hasProblem(),
              );

          return BottomNavigationBar(
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.onPrimary,
            unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
            onTap: ((index) {
              GoRouter.of(context).goNamed(
                _getPathByIndex(index),
              );
            }),
            currentIndex: _getCurrentTabIndex(),
            selectedLabelStyle: ScaleTextStyles.label
                .apply(color: Theme.of(context).colorScheme.onPrimary),
            unselectedLabelStyle: ScaleTextStyles.label
                .apply(color: Theme.of(context).colorScheme.onPrimary),
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: TabIconWidget(
                  icon: SvgPicture.asset(
                    'assets/icons/icon_wave_pulse.svg',
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  isActive: false,
                ),
                activeIcon: TabIconWidget(
                  icon: SvgPicture.asset(
                    'assets/icons/icon_wave_pulse.svg',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  isActive: true,
                ),
                label: context.locale.tabs_measurement,
              ),
              BottomNavigationBarItem(
                icon: TabIconWidget(
                  icon: SvgPicture.asset(
                    'assets/icons/icon_chart_pie_simple.svg',
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  isActive: false,
                ),
                activeIcon: TabIconWidget(
                  icon: SvgPicture.asset(
                    'assets/icons/icon_chart_pie_simple.svg',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  isActive: true,
                ),
                label: context.locale.tabs_results,
              ),
              BottomNavigationBarItem(
                icon: TabIconWidget(
                  icon: SvgPicture.asset(
                    'assets/icons/icon_dots_horizontal.svg',
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  isActive: false,
                  showWarning: showWarning,
                ),
                activeIcon: TabIconWidget(
                  icon: SvgPicture.asset(
                    'assets/icons/icon_dots_horizontal.svg',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  isActive: true,
                  showWarning: showWarning,
                ),
                label: context.locale.tabs_more,
              ),
            ],
          );
        },
      ),
    );
  }
}
