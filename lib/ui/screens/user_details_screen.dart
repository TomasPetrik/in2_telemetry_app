import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/sliver_name_value_row.dart';

class UserDetailScreen extends StatelessWidget {
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
              SliverGap(MediaQuery.of(context).viewPadding.top + Constants.appBarHeight),
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
              const SliverGap(Dimensions.padding24),
              SliverToBoxAdapter(
                child: Padding(
                  padding: Paddings.horizontal16,
                  child: HighlightedElevatedButton(
                    label: context.locale.user_detail_screen_logout_user,
                    onPressed: () {
                      getIt<AuthBloc>().add(LogoutUser(userAccount: userAccount));
                    },
                  ),
                ),
              ),
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
