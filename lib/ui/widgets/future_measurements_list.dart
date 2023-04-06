import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/future_measurement_item.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class FutureMeasurementsList extends StatelessWidget {
  const FutureMeasurementsList({
    super.key,
    required this.isMultiUser,
    required this.futureMeasurements,
  });

  final bool isMultiUser;
  final List<PlannedMeasurement> futureMeasurements;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureMeasurementItem(
                isMultiUser: isMultiUser,
                futureMeasurement: futureMeasurements[index],
              ),
              if (index != (futureMeasurements.length - 1))
                Container(
                  margin: Paddings.horizontal16,
                  height: 0.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          );
        },
        childCount: futureMeasurements.length,
      ),
    );
  }
}
