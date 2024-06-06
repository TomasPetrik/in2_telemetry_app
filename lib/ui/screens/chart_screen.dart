import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/chart_bloc/chart_bloc.dart';
import 'package:scalesoft_app/bloc/chart_bloc/chart_bloc_event.dart';
import 'package:scalesoft_app/bloc/chart_bloc/chart_bloc_state.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/chart_widget.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({
    super.key,
    required this.initDt,
    required this.userAccount,
    required this.measurementType,
  });

  final DateTime initDt;
  final UserModel userAccount;
  final MeasurementType measurementType;

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late CalendarMonth calendarMonth;
  final ChartBloc chartBloc = getIt<ChartBloc>();
  late UserModel userAccount;
  late MeasurementType measurementType;
  late DateTime initDt;
  late List<CarePlanContract> carePlans;
  final CarePlanDbProvider carePlanDbProvider = getIt<CarePlanDbProvider>();

  @override
  void initState() {
    initDt = widget.initDt;
    userAccount = widget.userAccount;
    measurementType = widget.measurementType;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocBuilder<ChartBloc, ChartBlocState>(
        bloc: chartBloc
          ..add(
            ChartBlocEvent.init(
              context,
              initDt,
              userAccount.id,
              measurementType,
              Theme.of(context).colorScheme.tertiary,
            ),
          ),
        builder: (context, state) {
          if (state.months == null ||
              state.months?.isEmpty == true ||
              state.currentYear == null ||
              state.currentMonth == null) {
            return const SizedBox.shrink();
          } else {
            return Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Gap(
                        MediaQuery.of(context).viewPadding.top +
                            Dimensions.twoLinedBarHeight,
                      ),
                      Expanded(
                        child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          controller: state.controller,
                          onPageChanged: (newPage) {
                            chartBloc.add(
                              ChartBlocEvent.onPageChanged(newPage),
                            );
                          },
                          itemBuilder: (context, index) {
                            final month = state.months![index];
                            return Padding(
                              key: ValueKey(index),
                              padding: Paddings.horizontal16,
                              child: ChartWidget(
                                measurementType: measurementType,
                                userAccount: userAccount,
                                calendarMonth: month,
                                svgDrawables: state.svgDrawables!,
                              ),
                            );
                          },
                          itemCount: state.months!.length,
                        ),
                      ),
                      Gaps.gap16,
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ScaleAppBar(
                    title: localization.chart_screen_title(
                      localization
                          .common_measurement_types_genitive(
                            measurementType.name,
                          )
                          .toLowerCase(),
                      "[${localization.common_measurement_units_types(measurementType.name)}]",
                    ),
                    subTitle:
                        '${userAccount.fullName} - ${localization.common_months(ConfigurationConstants.monthsInYear[state.currentMonth!]!)}',
                    customLeftWidget: SizedBox(
                      height: 24,
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: state.currentMonthIndex == 0
                                ? null
                                : () {
                                    chartBloc.add(
                                      const ChartBlocEvent.goToPreviousMonth(),
                                    );
                                  },
                            icon: SvgPicture.asset(
                              'assets/icons/icon_back.svg',
                              color: state.currentMonthIndex == 0
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.48)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Gaps.gap16,
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: state.currentMonthIndex ==
                                    state.months!.length - 1
                                ? null
                                : () {
                                    chartBloc.add(
                                      const ChartBlocEvent.goToNextMonth(),
                                    );
                                  },
                            icon: SvgPicture.asset(
                              'assets/icons/icon_arrow_sm_right.svg',
                              color: state.currentMonthIndex ==
                                      state.months!.length - 1
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.48)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    showClose: true,
                    isLandscape: true,
                    onCloseTap: () {},
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
