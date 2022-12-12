import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
    this.activeColor,
    this.backgroundColor,
  }) : super(key: key);

  final Color? activeColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: CircularProgressIndicator(
        strokeWidth: Dimensions.padding2,
        color: activeColor ?? ScaleColorsLight.content100,
        backgroundColor: backgroundColor ?? ScaleColorsLight.content80,
      ),
    );
  }
}
