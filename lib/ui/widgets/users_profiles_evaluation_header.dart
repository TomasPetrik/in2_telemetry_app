import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/progress_header.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class UsersProfilesEvaluationHeader extends StatelessWidget {
  const UsersProfilesEvaluationHeader({
    super.key,
    required this.userAccounts,
    required this.whenPeriod,
    required this.openWhenSelector,
  });

  final List<UserAccount> userAccounts;
  final ResultsWhenPeriod whenPeriod;
  final Function openWhenSelector;

  @override
  Widget build(BuildContext context) {
    List<ProgressItem> progressItems = [];

    final allPendingResults = getIt<Session>().getPendingResults();

    final List<MeasurementResult> offlineResults =
        MeasurementHelper.getOffilneResultsConverted(
      allPendingResults,
      [whenPeriod],
      null,
    );

    for (final userAccount in userAccounts) {
      final typedPlans = userAccount.carePlans!;

      final progress = EvaluationPlanHelper.getProgressFromPlans(
        carePlans: typedPlans,
        offlineResults: offlineResults,
        whenPeriod: whenPeriod,
      );

      if (progress != null) {
        progressItems.add(ProgressItem(userAccount.user.fullName, progress));
      }
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Gaps.gap16,
          ProgressHeader(
            whenPeriod: whenPeriod,
            openWhenSelector: openWhenSelector,
            progressItems: progressItems,
            label: translactions.common_plan_fulfillment,
          ),
          Gaps.gap24,
        ],
      ),
    );
  }
}
