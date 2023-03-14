import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class CalendarDayPlanned extends StatelessWidget {
  const CalendarDayPlanned({
    super.key,
    required this.plannedMeasurements,
  });

  final List<PlannedMeasurement>? plannedMeasurements;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadii.radius2,
      child: SizedBox(
        width: 20,
        height: 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List<int>.generate(
            plannedMeasurements != null
                ? min(plannedMeasurements!.length, 3)
                : 0,
            (i) => i + 1,
          )
              .map(
                (index) => Container(
                  height: 4,
                  width: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadii.radius2,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
