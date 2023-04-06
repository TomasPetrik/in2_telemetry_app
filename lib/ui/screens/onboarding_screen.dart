import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/onboarding_item_desc.dart';

class OnboardingScreen extends StatelessWidget with BottomSheetMixin {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: Paddings.horizontal16,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Gap(
                      MediaQuery.of(context).viewPadding.top +
                          Dimensions.appBarHeight,
                    ),
                    Gaps.gap48,
                    SvgPicture.asset(
                      'assets/icons/icon_onboard_user.svg',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    Gaps.gap36,
                    Text(
                      translactions
                          .onboarding_add_account_screen_add_account_subtitle,
                      textAlign: TextAlign.center,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    Gaps.gap24,
                    OnboardingItemDesc(
                      imagePath: 'assets/icons/icon_hospital_user.svg',
                      desc: translactions
                          .onboarding_add_account_screen_add_account_text1,
                    ),
                    OnboardingItemDesc(
                      imagePath: 'assets/icons/icon_shield_keyhole.svg',
                      desc: translactions
                          .onboarding_add_account_screen_add_account_text2,
                    ),
                    OnboardingItemDesc(
                      imagePath: 'assets/icons/icon_wave_pulse.svg',
                      desc: translactions
                          .onboarding_add_account_screen_add_account_text3,
                    ),
                    Gaps.gap24,
                    HighlightedElevatedButton(
                      label: translactions
                          .onboarding_add_account_screen_add_account_button,
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
                    Gaps.gap24,
                    HighlightedElevatedButton(
                      label: translactions
                          .onboarding_add_account_screen_add_account_how_it_works_button,
                      buttonType: ButtonType.secondary,
                      onPressed: () async {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BluredScaleAppBar(
              title:
                  translactions.onboarding_add_account_screen_add_account_title,
            ),
          ),
        ],
      ),
    );
  }
}
