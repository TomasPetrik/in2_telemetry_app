import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/user_detail_route.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/user_item_compound.dart';

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({
    super.key,
    required this.hospitalTitle,
    required this.userAccounts,
  });

  final String hospitalTitle;
  final List<UserAccount> userAccounts;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: getIt<AuthBloc>(),
      listener: (context, state) {
        final removedUser = state.whenOrNull(
          inactiveUserRemoved: (userAccount) {
            return userAccount;
          },
        );

        if (removedUser != null) {
          userAccounts.removeWhere(
            (userAccount) => userAccount.user.muid == removedUser.user.muid,
          );
        }
      },
      builder: (context, state) {
        return BlocBuilder<SyncBloc, SyncState>(
          bloc: getIt<SyncBloc>(),
          builder: (context, state) {
            return Material(
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverGap(
                        MediaQuery.of(context).viewPadding.top +
                            Dimensions.appBarHeight,
                      ),
                      const SliverGap(Dimensions.padding24),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, int index) {
                            final userAccount = userAccounts[index];
                            final bool showWarning = getIt<Session>()
                                    .getProblemIfExists(userAccount) !=
                                null;

                            return Column(
                              children: [
                                UserItemCompound(
                                  userAccount: userAccount,
                                  userItemCompoundType:
                                      UserItemCompoundType.settings,
                                  onUserSelected: (userAccount) {
                                    GoRouter.of(context).pushNamed(
                                      UserDetailRoute.name,
                                      extra: userAccount.user.muid,
                                    );
                                  },
                                  showWarning: showWarning,
                                ),
                                if (index != (userAccounts.length - 1))
                                  Gaps.gap24,
                              ],
                            );
                          },
                          childCount: userAccounts.length,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: BluredScaleAppBar(
                      title: hospitalTitle,
                      onBackTap: () {},
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
