import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';

part 'candle_data.freezed.dart';

@freezed
class CandleData with _$CandleData {
  CandleData._();

  factory CandleData({
    required MeasurementTypeContract? measurementType,
    required int timestamp,
    required double? high,
    required double? low,
  }) = _CandleData;

  static List<double?> computeMA(List<CandleData> data, [int period = 7]) {
    // If data is not at least twice as long as the period, return nulls.
    if (data.length < period * 2) return List.filled(data.length, null);

    final List<double?> result = [];
    // Skip the first [period] data points. For example, skip 7 data points.
    final firstPeriod = data.take(period).map((d) => d.low).whereType<double>();
    double ma = firstPeriod.reduce((a, b) => a + b) / firstPeriod.length;
    result.addAll(List.filled(period, null));

    // Compute the moving average for the rest of the data points.
    for (int i = period; i < data.length; i++) {
      final curr = data[i].low;
      final prev = data[i - period].low;
      if (curr != null && prev != null) {
        ma = (ma * period + curr - prev) / period;
        result.add(ma);
      } else {
        result.add(null);
      }
    }
    return result;
  }

  String get resultFormatted {
    return switch (measurementType) {
      null => '',
      MeasurementTypeContract.globalPosition => 'Lat: $highVal | Lon: $lowVal',
      MeasurementTypeContract.bloodPressure => '$highVal/$lowVal',
      MeasurementTypeContract.shortnessOfBreath => highVal == null
          ? ''
          : localization.shortness_of_breath_values(
              ShortnessOfBreathContract.values[highVal!.toInt()],
            ),
      MeasurementTypeContract.overallHealth => highVal == null
          ? ''
          : localization.overall_health_values(
              OverallHealthContract.values[highVal!.toInt()],
            ),
      _ => '$highVal',
    };
  }

  num? get highVal {
    if ([
      MeasurementTypeContract.temperature,
      MeasurementTypeContract.globalPosition,
    ].contains(measurementType)) {
      return high;
    } else {
      return high?.toInt();
    }
  }

  num? get lowVal {
    if ([
      MeasurementTypeContract.temperature,
      MeasurementTypeContract.globalPosition,
    ].contains(measurementType)) {
      return low;
    } else {
      return low?.toInt();
    }
  }

  @override
  String toString() => "<CandleData ($timestamp: $low)>";
}
