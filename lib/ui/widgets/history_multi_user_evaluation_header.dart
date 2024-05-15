import 'dart:core';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/ui/widgets/progress_header.dart';

class HistoryMultiUserEvaluationHeader extends StatelessWidget {
  const HistoryMultiUserEvaluationHeader({
    super.key,
    required this.results,
  });

  final List<MeasurementResultViewModel> results;

  @override
  Widget build(BuildContext context) {
    final resultsPerUser = results.where((x) => x.wasPlanned).groupListsBy((x) => x.user);

    final progressItems = resultsPerUser.entries.map((entry) {
      final reqCounts = entry.value
          .map(
            (x) => x.requiredCount,
          )
          .sum;

      final actualCounts = entry.value.map((x) => x.actualCount).sum;

      final evaluation = reqCounts == 0 ? 0 : ((actualCounts / reqCounts) * 100).toInt();

      return ProgressItem(
        entry.key.fullName,
        evaluation,
      );
    }).toList();

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Gaps.gap16,
          ProgressHeader(
            progressItems: progressItems,
            label: localization.results_history_screen_plan_of_day,
          ),
          Gaps.gap24,
        ],
      ),
    );
  }
}
