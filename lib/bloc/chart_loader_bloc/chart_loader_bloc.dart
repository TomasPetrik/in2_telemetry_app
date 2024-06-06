import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/chart_loader_bloc/chart_loader_bloc_event.dart';
import 'package:scalesoft_app/bloc/chart_loader_bloc/chart_loader_bloc_state.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/mapper/measurement_type_mapper.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/candle_data.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

@injectable
class ChartLoaderBloc extends Bloc<ChartLoaderBlocEvent, ChartLoaderBlocState> {
  final CarePlansRepository _carePlansRepository;
  final MeasurementsDbProvider _measurementsDbProvider;
  final MeasurementTypeMapper _measurementTypeMapper;

  ChartLoaderBloc(
    this._carePlansRepository,
    this._measurementsDbProvider,
    this._measurementTypeMapper,
  ) : super(const ChartLoaderBlocState()) {
    Future<List<CandleData>?> getCandles(
      MeasurementType measurementType,
      UserModel user,
      CalendarMonth calendarMonth,
    ) async {
      List<MeasurementDataContract> measurementResults;

      try {
        measurementResults = await _carePlansRepository.loadResults(
          userId: user.id,
          measurementType: _measurementTypeMapper.convert(measurementType),
          startDateTime: calendarMonth.monthStartDate.toIso8601String(),
          endDateTime: calendarMonth.monthEndDate.toIso8601String(),
        );
      } on DioException {
        debugPrint(
          'Not loaded  measurement for ${user.fullName}',
        );
        return null;
      }

      final candles = measurementResults.map(ResultsHelper.getCandleByMeasurementResult).toList();

      //1. Insert empty candles based on hour period with measurement
      //2. Add parallel measurements between this hour intervals

      final monthCandles = calendarMonth.getCalendarDays().fold<List<CandleData>>(
        [],
        (prevCandles, day) => [
          ...prevCandles,
          ...Iterable<int>.generate(24).toList().fold<List<CandleData>>([], (prevCandles, hours) {
            final startHourAt = day.startDt.add(Duration(hours: hours));
            final endHourAt = startHourAt.add(const Duration(hours: 1));
            final emptyCandle = CandleData(
              measurementType: null,
              timestamp: startHourAt.millisecondsSinceEpoch,
              high: null,
              low: null,
            );

            final measurementCandles = candles
                .where(
                  (candle) =>
                      candle.timestamp >= startHourAt.millisecondsSinceEpoch &&
                      candle.timestamp <= endHourAt.millisecondsSinceEpoch,
                )
                .toList();

            return [...prevCandles, emptyCandle, ...measurementCandles];
          }),
        ],
      );

      final offlineResults = await _measurementsDbProvider.getByUser(
        user.id,
        ofType: measurementType,
        from: calendarMonth.monthStartDate,
        to: calendarMonth.monthEndDate,
        isUploaded: false,
      );

      //3. Insert offline results
      for (final offlineResult in offlineResults) {
        final offlineCandle = ResultsHelper.getCandleByMeasurement(offlineResult);
        final hourStart = offlineResult.measuredAt.copyWith(
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        final hourEnd = offlineResult.measuredAt.copyWith(
          minute: 59,
          second: 59,
          millisecond: 0,
          microsecond: 0,
        );

        final hourCandles = monthCandles.where((candle) {
          return candle.timestamp <= hourEnd.millisecondsSinceEpoch &&
              candle.timestamp >= hourStart.millisecondsSinceEpoch;
        }).toList();

        final pivotCandle = hourCandles.last;
        final indexToBeInserted = monthCandles.indexOf(pivotCandle) + 1;
        monthCandles.insert(indexToBeInserted, offlineCandle);
      }

      return monthCandles;
    }

    on<ChartLoaderBlocEvent>((event, emit) async {
      await event.when(
        init: (measurementType, userAccount, calendarMonth) async {
          if (calendarMonth.monthStartDate.isAfter(DateTime.now())) {
            emit(
              ChartLoaderBlocState(month: calendarMonth, loading: false),
            );
            return;
          }

          emit(
            state.copyWith(month: calendarMonth, loading: true),
          );


          final candles = await getCandles(
            measurementType,
            userAccount,
            calendarMonth,
          );

          ChartResultType resultType;
          if (candles == null) {
            resultType = ChartResultType.error;
          } else if (candles.any((candle) => candle.measurementType != null) == true) {
            resultType = ChartResultType.hasData;
          } else {
            resultType = ChartResultType.noDataInMonth;
          }

          emit(
            ChartLoaderBlocState(
              month: calendarMonth,
              loading: false,
              candles: candles,
              resultType: resultType,
              wasResolved: true,
            ),
          );
        },
      );
    });
  }
}
