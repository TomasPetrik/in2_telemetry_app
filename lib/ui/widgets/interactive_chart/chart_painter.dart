import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/candle_data.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/painter_params.dart';

typedef TimeLabelGetter = String Function(int timestamp, int visibleDataCount);
typedef ValueLabelGetter = String Function(double value);
typedef OverlayInfoGetter = Map<DrawableRoot, String> Function(
  CandleData candle,
);

class ChartPainter extends CustomPainter {
  final PainterParams params;
  final TimeLabelGetter getTimeLabel;
  final ValueLabelGetter getValueLabel;
  final OverlayInfoGetter getOverlayInfo;
  final List<DrawableRoot> svgDrawables;

  ChartPainter({
    required this.params,
    required this.getTimeLabel,
    required this.getValueLabel,
    required this.getOverlayInfo,
    required this.svgDrawables,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw time labels (dates) & value labels
    _drawTimeLabels(canvas, params);
    _drawValueGridAndLabels(canvas, params);

    // Draw values, volumes & trend line
    canvas.save();
    canvas.clipRect(Offset.zero & Size(params.chartWidth, params.chartHeight));
    // canvas.drawRect(
    //   // apply yellow tint to clipped area (for debugging)
    //   Offset.zero & Size(params.chartWidth, params.chartHeight),
    //   Paint()..color = Colors.yellow[100]!,
    // );
    canvas.translate(params.xShift, 0);
    for (int i = 0; i < params.candles.length; i++) {
      _drawSingleDay(canvas, params, i, params.candles.length);
    }
    canvas.restore();

    // Draw tap highlight & overlay
    if (params.tapPosition != null) {
      if (params.tapPosition!.dx < params.chartWidth) {
        _drawTapHighlightAndOverlay(canvas, params);
      }
    }
  }

  void _drawTimeLabels(canvas, PainterParams params) {
    // We draw one time label per 90 pixels of screen width
    final lineCount = params.chartWidth ~/ 90;
    final gap = 1 / (lineCount + 1);
    for (int i = 1; i <= lineCount; i++) {
      double x = i * gap * params.chartWidth;
      final index = params.getCandleIndexFromOffset(x);
      if (index < params.candles.length) {
        final candle = params.candles[index];
        final visibleDataCount = params.candles.length;
        final timeTp = TextPainter(
          text: TextSpan(
            text: getTimeLabel(candle.timestamp, visibleDataCount),
            style: params.style.timeLabelStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();

        // Align texts towards vertical bottom
        final topPadding = params.style.timeLabelHeight - timeTp.height;
        timeTp.paint(
          canvas,
          Offset(x - timeTp.width / 2, params.chartHeight + topPadding),
        );
      }
    }
  }

  void _drawValueGridAndLabels(canvas, PainterParams params) {
    if(!params.showGridLines){
      return;
    }

    [0.0, 0.25, 0.5, 0.75, 1.0]
        .map((v) => ((params.maxValue - params.minValue) * v) + params.minValue)
        .forEach((y) {
      canvas.drawLine(
        Offset(0, params.fitValue(y)),
        Offset(params.chartWidth, params.fitValue(y)),
        Paint()
          ..strokeWidth = 0.5
          ..color = params.style.valueGridLineColor,
      );
      final valueTp = TextPainter(
        text: TextSpan(
          text: getValueLabel(y),
          style: params.style.valueLabelStyle,
        ),
      )
        ..textDirection = TextDirection.ltr
        ..layout();
      valueTp.paint(
        canvas,
        Offset(
          params.chartWidth + 4,
          params.fitValue(y) - valueTp.height / 2,
        ),
      );
    });
  }

  void _drawSingleDay(Canvas canvas, PainterParams params, int i, int count) {
    final candle = params.candles[i];
    final x = i * params.candleWidth;
    final thickWidth = max(params.candleWidth * 0.8, 0.8);
    // Draw value bar
    final high = candle.high;
    final low = candle.low;
    if (high != null && low != null) {
      final color = params.style.barColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            x - thickWidth / 2,
            params.fitValue(high),
            x + thickWidth / 2,
            params.fitValue(low),
          ),
          Radius.circular(thickWidth / 2),
        ),
        Paint()..color = color,
      );
    }
  }

  void _drawTapHighlightAndOverlay(canvas, PainterParams params) {
    final pos = params.tapPosition!;
    final pivot = params.getCandleIndexFromOffset(pos.dx);

    const delta = 10;
    final minPos = (pivot - delta) < 0 ? 0 : pivot - delta;
    final maxPos = (pivot + delta) > params.candles.length - 1
        ? params.candles.length - 1
        : pivot + delta;

    final Map<int, CandleData> possibleCandles = {};
    for (int i = minPos; i <= maxPos; i++) {
      if (params.candles[i].measurementType != null) {
        possibleCandles.putIfAbsent(i, () => params.candles[i]);
      }
    }

    final mostAccurateCandles = possibleCandles.entries.sorted(
      (a, b) => (a.key - pivot).abs().compareTo((b.key - pivot).abs()),
    );
    if (mostAccurateCandles.isEmpty) {
      return;
    }

    final candle = mostAccurateCandles.first.value;

    /*

    canvas.save();
    canvas.translate(params.xShift, 0.0);
    // Draw highlight bar (selection box)
    canvas.drawLine(
      Offset(pivot * params.candleWidth, 0.0),
      Offset(pivot * params.candleWidth, params.chartHeight),
      Paint()
        ..strokeWidth = max(params.candleWidth * 0.88, 1.0)
        ..color = params.style.selectionHighlightColor,
    );
    canvas.restore();
    */

    // Draw info pane
    _drawTapInfoOverlay(canvas, params, candle);
  }

  void _drawTapInfoOverlay(canvas, PainterParams params, CandleData candle) {
    const xGap = 16.0;
    const yGap = 10.0;

    TextPainter makeTP(String text) => TextPainter(
          text: TextSpan(
            text: text,
            style: params.style.overlayTextStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();

    final info = getOverlayInfo(candle);
    if (info.isEmpty) return;
    final icons = info.keys.toList();
    final values = info.values.map(makeTP).toList();

    final valuesMaxWidth = values.map((tp) => tp.width).reduce(max);
    final panelWidth = 4 * Dimensions.padding16 + valuesMaxWidth;
    final panelHeight = values.map((tp) => tp.height).reduce((a, b) => a + b) +
        2 * Dimensions.padding16 +
        (yGap * (values.length - 1));

    // Shift the canvas, so the overlay panel can appear near touch position.
    canvas.save();
    final pos = params.tapPosition!;
    const fingerSize = 32.0; // leave some margin around user's finger
    double dx;
    double dy;
    assert(params.size.width >= panelWidth, "Overlay panel is too wide.");
    if (pos.dx <= params.size.width / 2) {
      // If user touches the left-half of the screen,
      // we show the overlay panel near finger touch position, on the right.
      dx = pos.dx + fingerSize;
    } else {
      // Otherwise we show panel on the left of the finger touch position.
      dx = pos.dx - panelWidth - fingerSize;
    }
    dx = dx.clamp(0, params.size.width - panelWidth);
    dy = pos.dy - panelHeight - fingerSize;
    if (dy < 0) dy = 0.0;
    canvas.translate(dx, dy);

    // Draw the background for overlay panel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & Size(panelWidth, panelHeight),
        const Radius.circular(16),
      ),
      Paint()..color = params.style.overlayBackgroundColor,
    );

    // Draw texts
    var y = Dimensions.padding16;
    for (int i = 0; i < icons.length; i++) {
      final rowHeight = values[i].height;

      // Draw values (right align, vertical center)
      final valueY = y + (rowHeight - values[i].height) / 2; // vertical center
      values[i].paint(
        canvas,
        Offset(3 * Dimensions.padding16, valueY),
      );
      y += yGap + rowHeight;
    }

    canvas.restore();

    // Draw icons
    y = Dimensions.padding16;
    for (int i = 0; i < icons.length; i++) {
      final rowHeight = values[i].height;
      // Draw icons (left align, vertical center)
      final labelY = y + (rowHeight - values[i].height) / 2; // vertical center

      canvas.save();

      canvas.translate(dx + xGap, dy + labelY);

      svgDrawables[i].scaleCanvasToViewBox(
        canvas,
        Size(rowHeight, rowHeight),
      );
      svgDrawables[i].clipCanvasToViewBox(canvas);
      svgDrawables[i].draw(
        canvas,
        Offset(xGap, labelY) & Size(rowHeight, rowHeight),
      );

      canvas.restore();
      y += yGap + rowHeight;
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) =>
      params.shouldRepaint(oldDelegate.params);
}

extension ElementAtOrNull<E> on List<E> {
  E? at(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}
