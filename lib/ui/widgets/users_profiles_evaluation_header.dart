import 'package:flutter/material.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';
import 'package:scalesoft_app/ui/widgets/progress_header.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';

class UsersProfilesEvaluationHeader extends StatelessWidget {
  const UsersProfilesEvaluationHeader({
    super.key,
    required this.userAccounts,
    required this.whenPeriod,
    required this.openWhenSelector,
  });

  final List<UserModel> userAccounts;
  final ResultsWhenPeriod whenPeriod;
  final Function openWhenSelector;

  Future<List<ProgressItem>> getProgressItems() async {
    List<ProgressItem> progressItems = [];

    final offlineResults = await getIt<UserCubit>().getPendingResults();

    for (final user in userAccounts) {
      final plans = await getIt<CarePlanDbProvider>().getByUser(user.id);

      final progress = EvaluationPlanHelper.getProgressFromPlans(
        carePlans: plans,
        offlineResults: offlineResults,
        whenPeriod: whenPeriod,
      );

      if (progress != null) {
        progressItems.add(ProgressItem(user.fullName, progress));
      }
    }

    return progressItems;
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FutureBuilder(
        future: getProgressItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }

          return Column(
            children: [
              Gaps.gap16,
              ProgressHeader(
                whenPeriod: whenPeriod,
                openWhenSelector: openWhenSelector,
                progressItems: snapshot.data!,
                label: localization.common_plan_fulfillment,
              ),
              Gaps.gap24,
            ],
          );
        },
      ),
    );
  }
}
