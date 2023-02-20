import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/result_item.dart';

class ResultsList extends StatelessWidget {
  const ResultsList({
    super.key,
    required this.mResults,
    required this.userAccount,
    required this.multiUser,
    required this.whenPeriod,
  });

  final List<MeasurementResult> mResults;
  final UserAccount userAccount;
  final bool multiUser;
  final ResultsWhenPeriod whenPeriod;

  @override
  Widget build(BuildContext context) {
    return mResults.isEmpty
        ? SliverPadding(
            padding: Paddings.horizontal64,
            sliver: InfoPlaceholder(
              icon: SvgPicture.asset(
                'assets/icons/icon_chart_pie_simple_big.svg',
                color: Theme.of(context).colorScheme.tertiary,
              ),
              label: multiUser
                  ? context.locale
                      .results_screen_no_results(userAccount.user.fullName)
                  : context.locale.common_when_day_name(whenPeriod.name),
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResultItem(
                      mResult: mResults[index],
                    ),
                    if (index != (mResults.length - 1))
                      Container(
                        margin: Paddings.horizontal16,
                        height: 0.5,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                  ],
                );
              },
              childCount: mResults.length,
            ),
          );
  }
}
