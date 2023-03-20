import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/chart_loader_bloc/chart_loader_bloc.dart';
import 'package:scalesoft_app/bloc/chart_loader_bloc/chart_loader_bloc_event.dart';
import 'package:scalesoft_app/bloc/chart_loader_bloc/chart_loader_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/chart_style.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/interactive_chart.dart';
import 'package:scalesoft_app/ui/widgets/rotating_icon.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    super.key,
    required this.measurentType,
    required this.userAccount,
    required this.calendarMonth,
  });

  final CalendarMonth calendarMonth;
  final UserAccount userAccount;
  final MeasurementType measurentType;

  @override
  Widget build(BuildContext context) {
    final chartLoaderBloc = getIt<ChartLoaderBloc>();
    return BlocBuilder<ChartLoaderBloc, ChartLoaderBlocState>(
      bloc: chartLoaderBloc
        ..add(
          ChartLoaderBlocEvent.init(
            measurentType,
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
            if (candles?.isNotEmpty == true)
              Positioned.fill(
                top: Dimensions.padding16,
                child: InteractiveChart(
                  candles: candles!,
                  style: ChartStyle(
                    barColor: Theme.of(context).colorScheme.onTertiary,
                    timeLabelStyle: ScaleTextStyles.label.apply(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    valueLabelStyle: ScaleTextStyles.label.apply(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  /** Customize axis labels */
                  //timeLabel: (timestamp, visibleDataCount) => "📅",
                  valueLabel: (value) => '${value.round()}',
                  overlayInfo: (candle) => {
                    '📅': DateTime.fromMillisecondsSinceEpoch(candle.timestamp)
                        .toRegularDate(),
                    '🕑': DateTime.fromMillisecondsSinceEpoch(candle.timestamp)
                        .toTimeShort(),
                    context.locale.common_measurement_types(
                      candle.measurementType?.name ?? '',
                    ): candle.resultFormatted,
                  },
                  /** Callbacks */
                  // onTap: (candle) => print("user tapped on $candle"),
                ),
              ),
            if (state.loading == true)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: Constants.twoLinedBarHeight,
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
