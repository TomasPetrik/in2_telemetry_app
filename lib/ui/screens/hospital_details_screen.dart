import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/user_detail_route.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/user_item_compound.dart';

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({
    super.key,
    required this.hospital,
    required this.userAccounts,
  });

  final Hospital hospital;
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
            final bool showWarning = userAccounts.any(
              (userAccount) => getIt<Session>().userHasProblem(userAccount),
            );

            return Material(
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverGap(
                        MediaQuery.of(context).viewPadding.top +
                            Constants.appBarHeight,
                      ),
                      const SliverGap(Dimensions.padding24),
                      SliverToBoxAdapter(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final userAccount = userAccounts[index];
                            return UserItemCompound(
                              userAccount: userAccount,
                              userItemCompoundType:
                                  UserItemCompoundType.settings,
                              onUserSelected: (userAccount) {
                                GoRouter.of(context).pushNamed(
                                  UserDetailRoute.name,
                                  extra: userAccount,
                                );
                              },
                              showWarning: showWarning,
                            );
                          },
                          separatorBuilder: (_, __) {
                            return Gaps.gap24;
                          },
                          itemCount: userAccounts.length,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ScaleAppBar(
                      title: hospital.title,
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
