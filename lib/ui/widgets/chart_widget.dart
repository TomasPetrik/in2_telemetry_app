import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/chart_loader_bloc/chart_loader_bloc.dart';
import 'package:scalesoft_app/bloc/chart_loader_bloc/chart_loader_bloc_event.dart';
import 'package:scalesoft_app/bloc/chart_loader_bloc/chart_loader_bloc_state.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/chart_style.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/interactive_chart.dart';
import 'package:scalesoft_app/ui/widgets/rotating_icon.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    super.key,
    required this.measurementType,
    required this.userAccount,
    required this.calendarMonth,
    required this.svgDrawables,
  });

  final CalendarMonth calendarMonth;
  final UserModel userAccount;
  final MeasurementType measurementType;
  final List<PictureInfo> svgDrawables;

  @override
  Widget build(BuildContext context) {
    final chartLoaderBloc = getIt<ChartLoaderBloc>();
    return BlocBuilder<ChartLoaderBloc, ChartLoaderBlocState>(
      bloc: chartLoaderBloc
        ..add(
          ChartLoaderBlocEvent.init(
            measurementType,
            userAccount,
            calendarMonth,
          ),
        ),
      builder: (context, state) {
        final candles = state.candles;

        if (state.month != null) {
          calendarMonth.wasResolved = state.wasResolved;
        }

        return Stack(
          children: [
            Positioned.fill(
              top: Dimensions.padding16,
              child: state.resultType == null
                  ? const SizedBox.shrink()
                  : [ChartResultType.noDataInMonth, ChartResultType.error]
                          .contains(state.resultType)
                      ? _ChartPlaceHolder(state.resultType!)
                      : InteractiveChart(
                          candles: candles!,
                          style: ChartStyle(
                            barColor: Theme.of(context).colorScheme.onTertiary,
                            timeLabelStyle: ScaleTextStyles.label.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            valueLabelStyle: ScaleTextStyles.label.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            overlayBackgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            //.withOpacity(0.8),
                            overlayTextStyle: ScaleTextStyles.label.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          svgDrawables: svgDrawables,
                          valueLabel: (value) => '${value.round()}',
                          overlayInfo: (candle) => {
                            svgDrawables[0]:
                                DateTime.fromMillisecondsSinceEpoch(
                              candle.timestamp,
                            ).dateFormat,
                            svgDrawables[1]:
                                DateTime.fromMillisecondsSinceEpoch(
                              candle.timestamp,
                            ).timeFormatShort,
                            svgDrawables[2]: candle.resultFormatted,
                          },
                          showGridLines: switch (measurementType) {
                            MeasurementType.temperature => true,
                            MeasurementType.bloodPressure => true,
                            MeasurementType.oxygenSaturation => true,
                            MeasurementType.steps => true,
                            MeasurementType.globalPosition => true,
                            MeasurementType.heartRate => true,
                            MeasurementType.ews => false,
                            MeasurementType.respiratoryRate => true,
                            MeasurementType.shortnessOfBreath => false,
                            MeasurementType.overallHealth => false,
                            MeasurementType.battery => false,
                          },
                        ),
            ),
            if (state.loading == true)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: Dimensions.twoLinedBarHeight,
                child: Center(
                  child: RotatingIcon(
                    child: SvgPicture.asset(
                      'assets/icons/icon_loader.svg',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChartPlaceHolder extends StatelessWidget {
  const _ChartPlaceHolder(this.chartLoadedResult);

  final ChartResultType chartLoadedResult;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: SizedBox.shrink(),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                chartLoadedResult == ChartResultType.error
                    ? 'assets/icons/icon_triangle_exclamation_big.svg'
                    : 'assets/icons/icon_wave_pulse_big.svg',
                color: chartLoadedResult == ChartResultType.error
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.tertiary,
              ),
              Gaps.gap24,
              Text(
                chartLoadedResult == ChartResultType.error
                    ? localization.chart_placeholder_error_loading_data
                    : localization.chart_placeholder_no_data_in_month,
                style: ScaleTextStyles.text.apply(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Expanded(
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
