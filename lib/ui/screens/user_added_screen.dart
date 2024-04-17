import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/image_widget.dart';

class UserAddedScreen extends StatelessWidget with BottomSheetMixin {
  const UserAddedScreen({
    super.key,
    required this.userAccount,
  });

  final UserModel userAccount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            left: 16,
            right: 16,
            child: Column(
              children: [
                Gap(
                  MediaQuery.of(context).viewPadding.top +
                      Dimensions.appBarHeight,
                ),
                Gaps.gap48,
                Container(
                  width: 96,
                  height: 96,
                  padding: Paddings.all8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadii.radius8,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: ImageWidget(
                    userAccount.hospital.iconPath,
                  ),
                ),
                Gaps.gap24,
                Padding(
                  padding: const EdgeInsets.only(
                    left: Dimensions.padding48,
                    right: Dimensions.padding48,
                  ),
                  child: Text(
                    localization.onboarding_account_added_screen_user_added(
                      userAccount.fullName,
                    ),
                    style: ScaleTextStyles.text.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Gaps.gap24,
                HighlightedElevatedButton(
                  label: localization
                      .onboarding_account_added_screen_continue_to_app,
                  onPressed: () async {
                    getIt<ContentBloc>().add(
                      SwitchUserContentEvent(userId: userAccount.id),
                    );
                  },
                ),
                Gaps.gap24,
                HighlightedElevatedButton(
                  label: localization
                      .onboarding_account_added_screen_add_other_account,
                  buttonType: ButtonType.secondary,
                  onPressed: () async {
                    final hospitalSelection =
                        await selectHospital(context: context);
                    if (hospitalSelection?.selectedHospital != null) {
                      getIt<AuthBloc>().add(
                        Authenticate(
                          hospital: hospitalSelection!.selectedHospital!,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredScaleAppBar(
              title: localization
                  .onboarding_account_added_screen_add_account_title,
            ),
          ),
        ],
      ),
    );
  }
}
