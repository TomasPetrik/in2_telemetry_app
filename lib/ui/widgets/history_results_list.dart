import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/history_result_item.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class HistoryResultsList extends StatelessWidget {
  const HistoryResultsList({
    super.key,
    required this.isMultiUser,
    required this.historicMeasurements,
  });

  final bool isMultiUser;
  final List<HistoricMeasurement> historicMeasurements;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HistoryResultItem(
                isMultiUser: isMultiUser,
                historicMeasurement: historicMeasurements[index],
              ),
              if (index != (historicMeasurements.length - 1))
                Container(
                  margin: Paddings.horizontal16,
                  height: 0.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          );
        },
        childCount: historicMeasurements.length,
      ),
    );
  }
}
