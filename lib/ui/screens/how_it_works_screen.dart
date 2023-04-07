import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

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
                SliverToBoxAdapter(
                  child: Text(
                    translactions.how_it_works_screen_desc,
                    style: ScaleTextStyles.text.apply(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
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
            child: BluredScaleAppBar(
              title: translactions.how_it_works_screen_title,
              showClose: true,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
