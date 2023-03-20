import 'package:flutter/material.dart';

class ChartStyle {
  /// The percentage height of volume.
  ///

  /// The padding on the right-side of the chart.
  final double valueLabelWidth;

  /// The padding on the bottom-side of the chart.
  ///
  /// Defaults to 24.0, date/time labels is drawn vertically bottom-aligned,
  /// thus adjusting this value would also control the padding between
  /// the chart and the date/time labels.
  final double timeLabelHeight;

  /// The style of date/time labels (on the bottom of the chart).
  final TextStyle timeLabelStyle;

  /// The style of value labels (on the right of the chart).
  final TextStyle valueLabelStyle;

  /// The style of overlay texts. These texts are drawn on top of the
  /// background color specified in [overlayBackgroundColor].
  ///
  /// This appears when user clicks on the chart.
  final TextStyle overlayTextStyle;

  /// The color to use when the `close` value is higher than `open` value.
  final Color barColor;

  /// The color of the value grid line.
  final Color valueGridLineColor;

  /// The highlight color. This appears when user clicks on the chart.
  final Color selectionHighlightColor;

  /// The background color of the overlay.
  ///
  /// This appears when user clicks on the chart.
  final Color overlayBackgroundColor;

  const ChartStyle({
    this.valueLabelWidth = 48.0,
    this.timeLabelHeight = 24.0,
    this.timeLabelStyle = const TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
    this.valueLabelStyle = const TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
    this.overlayTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
    this.barColor = Colors.green,
    this.valueGridLineColor = Colors.grey,
    this.selectionHighlightColor = const Color(0x33757575),
    this.overlayBackgroundColor = const Color(0xEE757575),
  });
}
