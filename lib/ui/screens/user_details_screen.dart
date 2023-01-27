import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/care_plan_detail_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/care_plan_item.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/sliver_name_value_row.dart';

class UserDetailScreen extends StatelessWidget with BottomSheetMixin {
  const UserDetailScreen({
    super.key,
    required this.userAccount,
  });

  final UserAccount userAccount;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverGap(
                MediaQuery.of(context).viewPadding.top + Constants.appBarHeight,
              ),
              SliverPadding(
                padding: Paddings.left16,
                sliver: SliverToBoxAdapter(
                  child: Text(
                    context.locale.user_detail_screen_measurement_plans,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
              if (userAccount.carePlans?.isNotEmpty == true) ...[
                const SliverGap(Dimensions.padding26),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, int index) {
                      final carePlan = userAccount.carePlans![index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              GoRouter.of(context).pushNamed(
                                CarePlanDetailRoute.name,
                                extra: carePlan,
                              );
                            },
                            child: Padding(
                              padding: Paddings.horizontal16,
                              child: CarePlanItem(
                                carePlan: carePlan,
                              ),
                            ),
                          ),
                          if (index != (userAccount.carePlans!.length - 1))
                            Gaps.gap16,
                        ],
                      );
                    },
                    childCount: userAccount.carePlans!.length,
                  ),
                ),
              ],
              const SliverGap(Dimensions.padding24),
              SliverPadding(
                padding: Paddings.left16,
                sliver: SliverToBoxAdapter(
                  child: Text(
                    context.locale.user_detail_screen_user_info,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
              const SliverGap(Dimensions.padding24),
              SliverNameValueRow(
                name: context.locale.user_detail_screen_user_name,
                value: userAccount.user.firstNames[0],
              ),
              const SliverGap(Dimensions.padding8),
              SliverNameValueRow(
                name: context.locale.user_detail_screen_user_surname,
                value: userAccount.user.lastNames[0],
              ),
              if (userAccount.user.phoneNumbers?.isNotEmpty == true) ...[
                const SliverGap(Dimensions.padding8),
                SliverNameValueRow(
                  name: context.locale.user_detail_screen_user_phone,
                  value: userAccount.user.phoneNumbers![0],
                ),
              ],
              if (userAccount.user.emailAddresses?.isNotEmpty == true) ...[
                const SliverGap(Dimensions.padding8),
                SliverNameValueRow(
                  name: context.locale.user_detail_screen_user_email,
                  value: userAccount.user.emailAddresses![0],
                ),
              ],
              if (userAccount.hasParent == false) ...[
                const SliverGap(Dimensions.padding24),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: Paddings.horizontal16,
                    child: HighlightedElevatedButton(
                      label: context.locale.user_detail_screen_remove_account,
                      buttonType: ButtonType.alert,
                      onPressed: () async {
                        final confirmed = await showAccounRemovalConfirmation(
                          context: context,
                          accountName: userAccount.user.fullName,
                        );

                        if (confirmed == true) {
                          getIt<AuthBloc>()
                              .add(LogoutUser(userAccount: userAccount));
                        }
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScaleAppBar(
              title: userAccount.user.fullName,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
