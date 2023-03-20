import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/candle_data.dart';

part 'chart_loader_bloc_state.freezed.dart';

@freezed
class ChartLoaderBlocState with _$ChartLoaderBlocState {
  const factory ChartLoaderBlocState({
    List<CandleData>? candles,
    CalendarMonth? month,
    DateTime? selectedDayDt,
    bool? loading,
    bool? wasResolved,
  }) = _CalendarServiceBlocState;
}
