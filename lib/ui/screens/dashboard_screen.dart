import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/screens/select_device_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/action_widget.dart';
import 'package:scalesoft_app/ui/widgets/blured_user_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
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

class _DashboardPageState extends State<DashboardPage> with BottomSheetMixin {
  final carePlanBloc = getIt<CarePlanBloc>();
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarePlanBloc, CarePlanBlocState>(
      bloc: carePlanBloc,
      builder: (context, state) {
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
              navigationHeader: MeasurementHeader(
                measurementTime: state.selectedPeriod ?? PeriodType.today,
                openTimeSelector: () async {
                  final selected = await showMeasurementTime(context, state.selectedPeriod);
                  if (selected?.selectedPeriod != null) {
                    carePlanBloc.add(CarePlanTimePeriodEvent(selected!.selectedPeriod!));
                  }else if(selected?.showCalendar == true){
                    //TODO.. show calendar
                  }
                },
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
                    const SliverGap(Dimensions.padding16),
                    SliverPadding(
                      padding: Paddings.horizontal16,
                      sliver: SliverToBoxAdapter(
                        child: HighlightedElevatedButton(
                          label: context.locale.common_manual_measurement,
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const SelectDeviceScreen(),
                                fullscreenDialog: true,
                              ),
                            );
                          },
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
      },
    );
  }
}
