import 'package:flutter/material.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
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
            label: context.locale.results_history_screen_plan_of_day,
          ),
          Gaps.gap24,
        ],
      ),
    );
  }
}
