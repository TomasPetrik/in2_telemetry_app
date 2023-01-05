import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/storage.dart';
import 'package:scalesoft_app/ui/screens/auth_screen.dart';
import 'package:scalesoft_app/ui/screens/home_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';

class HospitalUsersScreen extends StatelessWidget {
  const HospitalUsersScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final authBloc = getIt<AuthBloc>();
    final accountDbProvider = getIt<AccountDbProvider>();
    final session = getIt<Session>();

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
              BlocConsumer<AuthBloc, AuthState>(
                bloc: authBloc,
                listener: (context, state) {
                  state.whenOrNull(
                    logoutSuccess: () {
                      final lastUsedAccount = accountDbProvider.getLast();

                      if (lastUsedAccount != null) {
                        session.userAccount = lastUsedAccount;
                        session.token = lastUsedAccount.authToken;

                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (c) => HomeScreen(
                              userAccount: lastUsedAccount,
                            ),
                          ),
                          (route) => false,
                        );
                      } else {
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) => AuthScreen()),
                          (route) => false,
                        );
                      }
                    },
                  );
                },
                builder: (context, state) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: Paddings.horizontal16,
                      child: HighlightedElevatedButton(
                        label: context.locale.user_detail_screen_logout_user,
                        onPressed: () {
                          authBloc.add(const LogoutUser());
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScaleAppBar(
              title: title,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
