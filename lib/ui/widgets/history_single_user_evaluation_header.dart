import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/ui/widgets/progress_header.dart';

class HistorySingleUserEvaluationHeader extends StatelessWidget {
  const HistorySingleUserEvaluationHeader({
    super.key,
    required this.results,
  });

  final List<MeasurementResultViewModel> results;

  @override
  Widget build(BuildContext context) {
    final plannedMeasurementsPerType =
        results.where((x) => x.wasPlanned).groupListsBy((evDay) => evDay.measurementType);

    final progressItems = plannedMeasurementsPerType.entries.map(
      (resultsWithType) {
        final resultsOfType = resultsWithType.value;

        final reqCounts = resultsOfType.map((x) => x.requiredCount).sum;

        final actualCounts = resultsOfType.map((x) => x.actualCount).sum;

        final measurementTypeEvaluation = reqCounts == 0 ? 0 : ((actualCounts / reqCounts) * 100).toInt();

        return ProgressItem(
          localization.common_measurement_types(
            resultsWithType.key.name,
          ),
          measurementTypeEvaluation,
        );
      },
    ).toList();

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Gaps.gap16,
          progressItems.isEmpty
              ? const SizedBox.shrink()
              : ProgressHeader(
                  progressItems: progressItems,
                  label: localization.results_history_screen_plan_of_day,
                ),
          Gaps.gap24,
        ],
      ),
    );
  }
}
