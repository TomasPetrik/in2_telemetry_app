import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class UserAppBar extends StatelessWidget with BottomSheetMixin {
  const UserAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final session = getIt<Session>();
    final sessionAccounts = session.getSessionAccounts();

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
        ),
        child: SizedBox(
          height: Dimensions.twoLinedBarHeight,
          child: Padding(
            padding: const EdgeInsets.only(
              top: Dimensions.padding16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        child: IconButton(
                          onPressed: () {
                            switchUser(
                              context: context,
                              supportMultiUser: session.supportMultiUser(),
                            ).then((switchUserResult) {
                              if (switchUserResult?.activeMultiUser == true) {
                                getIt<ContentBloc>().add(
                                  const SwitchMultiUserContentEvent(),
                                );
                              } else if (switchUserResult?.addNewUser == true) {
                                selectHospital(context: context).then(
                                  (hospitalSelection) {
                                    if (hospitalSelection?.selectedHospital !=
                                        null) {
                                      getIt<AuthBloc>().add(
                                        Authenticate(
                                          hospital: hospitalSelection!
                                              .selectedHospital!,
                                        ),
                                      );
                                    }
                                  },
                                );
                              } else if (switchUserResult?.selectedUser !=
                                  null) {
                                getIt<ContentBloc>().add(
                                  SwitchUserContentEvent(
                                    userAccount:
                                        switchUserResult!.selectedUser!,
                                  ),
                                );
                              }
                            });
                          },
                          padding: EdgeInsets.zero,
                          icon: SvgPicture.asset(
                            'assets/icons/icon_hospital_user.svg',
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          style: ScaleTextStyles.textAccent.apply(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          session.isMultiUser == true
                              ? localization.common_all_accounts
                              : sessionAccounts[0].hospital?.title ?? '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
                Gaps.gap6,
                Text(
                  style: ScaleTextStyles.label.apply(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  session.isMultiUser == true
                      ? '${sessionAccounts.first.user.fullName}'
                          ' ${sessionAccounts.length > 1 ? localization.common_plus_n_others(sessionAccounts.length - 1) : ''}'
                      : sessionAccounts[0].user.fullName,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
