import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/dashboard_route.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';

class RegisterDeviceSuccessScreen extends StatelessWidget {
  const RegisterDeviceSuccessScreen({super.key, required this.deviceName});

  final String deviceName;

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).viewPadding.top;
    final fixedHeight = topGap + Dimensions.appBarHeight;
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            left: Dimensions.padding16,
            right: Dimensions.padding16,
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverGap(fixedHeight),
                const SliverGap(Dimensions.padding16),
                const SliverGap(Dimensions.padding40),
                SliverToBoxAdapter(
                  child: SvgPicture.asset(
                    'assets/icons/icon_circle_check_huge.svg',
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                const SliverGap(Dimensions.padding48),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: Paddings.horizontal48,
                    child: Text(
                      localization.register_device_success_screen_desc,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SliverGap(Dimensions.padding24),
                SliverToBoxAdapter(
                  child: HighlightedElevatedButton(
                    label: localization.common_close,
                    onPressed: () {
                      GoRouter.of(context).goNamed(DashboardRoute.name);
                    },
                    buttonType: ButtonType.secondary,
                  ),
                ),
                const SliverGap(Dimensions.padding16),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredScaleAppBar(
              title: deviceName,
              showClose: true,
            ),
          ),
        ],
      ),
    );
  }
}
