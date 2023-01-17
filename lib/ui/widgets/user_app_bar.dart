import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class UserAppBar extends StatelessWidget with BottomSheetMixin {
  const UserAppBar({
    super.key,
    required this.userAccount,
  });

  final UserAccount userAccount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Theme.of(context).backgroundColor.withOpacity(0.5),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
        ),
        child: SizedBox(
          height: Constants.twoLinedBarHeight,
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
                          onPressed: () async {
                            final switchUserResult = await switchUser(context: context);

                            if (switchUserResult?.addNewUser == true) {
                              final hospitalSelection = await selectHospital(context: context);
                              if (hospitalSelection?.selectedHospital != null) {
                                getIt<AuthBloc>().add(Authenticate(hospital: hospitalSelection!.selectedHospital!));
                              }
                            } else if (switchUserResult?.selectedUser != null) {
                              getIt<ContentBloc>()
                                  .add(SwitchUserContentEvent(userAccount: switchUserResult!.selectedUser!));
                            }
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
                          style: ScaleTextStyles.textAccent,
                          userAccount.user.fullName,
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
                    color: Theme.of(context).hintColor,
                  ),
                  userAccount.hospital?.title ?? '',
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
