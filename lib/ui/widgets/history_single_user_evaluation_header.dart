import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/progress_header.dart';

class HistorySingleUserEvaluationHeader extends StatelessWidget {
  const HistorySingleUserEvaluationHeader({
    super.key,
    required this.userEvaluationDay,
  });

  final UserEvaluationDay userEvaluationDay;

  @override
  Widget build(BuildContext context) {
    final measurementTypesCarePlans = userEvaluationDay.carePlanFulfillments
        .where((carePlanFulfillment) => carePlanFulfillment.getReqCount() > 0)
        .groupListsBy((element) => element.carePlan.activity.measurementType);

    final progressItems = measurementTypesCarePlans.entries.map(
      (carePlanFulfillment) {
        final measurementTypeCarePlans = carePlanFulfillment.value;

        final reqCounts = measurementTypeCarePlans.fold(
          0,
          (previousValue, carePlanEvaluation) =>
              previousValue + carePlanEvaluation.getReqCount(),
        );

        final actualCounts = measurementTypeCarePlans.fold(
          0,
          (previousValue, carePlanEvaluation) =>
              previousValue + carePlanEvaluation.getActualCount(),
        );

        final measurementTypeEvaluation =
            reqCounts == 0 ? 0 : ((actualCounts / reqCounts) * 100).toInt();

        return ProgressItem(
          context.locale.common_measurement_types(
            carePlanFulfillment.key.name,
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
                  label: context.locale.results_history_screen_plan_of_day,
                ),
          Gaps.gap24,
        ],
      ),
    );
  }
}
