import 'package:flutter/material.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/progress_header.dart';

class HistoryMultiUserEvaluationHeader extends StatelessWidget {
  const HistoryMultiUserEvaluationHeader({
    super.key,
    required this.usersEvaluationsDay,
  });

  final List<UserEvaluationDay> usersEvaluationsDay;

  @override
  Widget build(BuildContext context) {
    List<ProgressItem> progressItems = usersEvaluationsDay
        .map(
          (userEvaluationDay) => ProgressItem(
            userEvaluationDay.userName,
            userEvaluationDay.evaluationPercentage,
          ),
        )
        .toList();

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Gaps.gap16,
          ProgressHeader(
            progressItems: progressItems,
            label: translactions.results_history_screen_plan_of_day,
          ),
          Gaps.gap24,
        ],
      ),
    );
  }
}
