import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/action_widget.dart';
import 'package:scalesoft_app/ui/widgets/blured_user_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    Key? key,
    required this.userInfo,
  }) : super(key: key);

  final UserInfo userInfo;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthBloc authBloc = getIt<AuthBloc>();

  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NavigationScreen(
          topHeaderHeight: Dimensions.padding16 + Constants.actionActiveWidgetHeight + Dimensions.padding26,
          topHeader: Column(
            children: [
              Gaps.gap16,
              Flexible(
                child: ActionWidget(
                  when: DateTime.now(),
                  activityType: ActivityType.active,
                ),
              ),
              /*
              Flexible(
                child: ActionWidget(
                  when: DateTime.now(),
                  activityType: ActivityType.passive,
                ),
              ),
              */
              Gaps.gap26,
            ],
          ),
          navigationHeader: const MeasurementHeader(
            measurementTime: MeasurementTime.tomorrow,
          ),
          tabs: [
            NavigationBarTabItem(
              label: 'Vsechna',
              topSlivers: [],
              slivers: [
                SliverPadding(
                  padding: Paddings.horizontal16,
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      color: Colors.red,
                      height: 200,
                      child: const Text('Vsechna'),
                    ),
                  ),
                )
              ],
            ),
            NavigationBarTabItem(
              label: 'Teplota',
              topSlivers: [],
              slivers: [
                SliverPadding(
                  padding: Paddings.horizontal16,
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      color: Colors.yellow,
                      height: 200,
                      child: const Text('Teplota'),
                    ),
                  ),
                ),
              ],
            ),
            NavigationBarTabItem(
              label: 'Krev',
              slivers: [
                SliverPadding(
                  padding: Paddings.horizontal16,
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      color: Colors.blue,
                      height: 200,
                      child: const Text('Krev'),
                    ),
                  ),
                ),
              ],
            ),
            NavigationBarTabItem(
              label: 'Tlak',
              slivers: [
                SliverPadding(
                  padding: Paddings.horizontal16,
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      color: Colors.green,
                      height: 200,
                      child: const Text('Tlak'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BluredUserAppBar(
            userInfo: widget.userInfo,
          ),
        ),
      ],
    );
  }
}
