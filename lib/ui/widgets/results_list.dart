import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/routers/routes/chart_screen_route.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/result_item.dart';

class ResultsList extends StatelessWidget {
  const ResultsList({
    super.key,
    required this.mResults,
    required this.whenPeriod,
  });

  final List<MeasurementResult> mResults;
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
              label: context.locale.results_screen_no_results_at_period(
                context.locale.common_when_day_name(whenPeriod.name),
              ),
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        final userAccount = getIt<AccountDbProvider>()
                            .get(mResults[index].userId!);

                        if (userAccount?.viewOwnMeasurementData == true) {
                          GoRouter.of(context).pushNamed(
                            ChartRoute.name,
                            params: {
                              'userId': mResults[index].userId!,
                              'dateTime': mResults[index]
                                  .measurementDateTime
                                  .toIso8601String(),
                              'measurementType':
                                  mResults[index].measurementType!.name,
                            },
                          );
                        }
                      },
                      child: ResultItem(
                        mResult: mResults[index],
                      ),
                    ),
                    if (index != (mResults.length - 1))
                      Container(
                        margin: Paddings.horizontal16,
                        height: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                );
              },
              childCount: mResults.length,
            ),
          );
  }
}
