import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/candle_data.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/chart_style.dart';

class PainterParams {
  final List<CandleData> candles;
  final ChartStyle style;
  final Size size;
  final double candleWidth;
  final double startOffset;

  final double maxValue;
  final double minValue;

  final double xShift;
  final Offset? tapPosition;

  PainterParams({
    required this.candles,
    required this.style,
    required this.size,
    required this.candleWidth,
    required this.startOffset,
    required this.maxValue,
    required this.minValue,
    required this.xShift,
    required this.tapPosition,
  });

  double get chartWidth => // width without value labels
      size.width - style.valueLabelWidth;

  double get chartHeight => // height without time labels
      size.height - style.timeLabelHeight;

  double get valueHeight => chartHeight;

  int getCandleIndexFromOffset(double x) {
    final adjustedPos = x - xShift + candleWidth / 2;
    final i = adjustedPos ~/ candleWidth;
    return i;
  }

  double fitValue(double y) => valueHeight * (maxValue - y) / (maxValue - 0);

  static PainterParams lerp(PainterParams a, PainterParams b, double t) {
    double lerpField(double Function(PainterParams p) getField) =>
        lerpDouble(getField(a), getField(b), t)!;
    return PainterParams(
      candles: b.candles,
      style: b.style,
      size: b.size,
      candleWidth: b.candleWidth,
      startOffset: b.startOffset,
      maxValue: lerpField((p) => p.maxValue),
      minValue: lerpField((p) => p.minValue),
      xShift: b.xShift,
      tapPosition: b.tapPosition,
    );
  }

  bool shouldRepaint(PainterParams other) {
    if (candles.length != other.candles.length) return true;

    if (size != other.size ||
        candleWidth != other.candleWidth ||
        startOffset != other.startOffset ||
        xShift != other.xShift) return true;

    if (maxValue != other.maxValue || minValue != other.minValue) return true;

    if (tapPosition != other.tapPosition) return true;

    if (style != other.style) return true;

    return false;
  }
}

class PainterParamsTween extends Tween<PainterParams> {
  PainterParamsTween({
    PainterParams? begin,
    required PainterParams end,
  }) : super(begin: begin, end: end);

  @override
  PainterParams lerp(double t) => PainterParams.lerp(begin ?? end!, end!, t);
}
