import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/user_detail_route.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/user_item_compound.dart';

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({
    super.key,
    required this.hospitalTitle,
    required this.userAccounts,
  });

  final String hospitalTitle;
  final List<UserModel> userAccounts;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      bloc: getIt<SyncBloc>(),
      builder: (context, state) {
        return Material(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverGap(
                    MediaQuery.of(context).viewPadding.top + Dimensions.appBarHeight,
                  ),
                  const SliverGap(Dimensions.padding24),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, int index) {
                        final userAccount = userAccounts[index];
                        const bool showWarning = false;
                        // getIt<Session>().getProblemIfExists(userAccount) != null; TODO;

                        return Column(
                          children: [
                            UserItemCompound(
                              userAccount: userAccount,
                              userItemCompoundType: UserItemCompoundType.settings,
                              onUserSelected: (userAccount) {
                                GoRouter.of(context).pushNamed(
                                  UserDetailRoute.name,
                                  extra: userAccount.id,
                                );
                              },
                              showWarning: showWarning,
                            ),
                            if (index != (userAccounts.length - 1)) Gaps.gap24,
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
                child: BlurredScaleAppBar(
                  title: hospitalTitle,
                  onBackTap: () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
