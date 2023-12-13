import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/oss_licenses.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:url_launcher/url_launcher.dart';

class LicenceDetailScreen extends StatelessWidget {
  final Package package;

  const LicenceDetailScreen({super.key, required this.package});

  String _bodyText() {
    return package.license!.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          ListView(
            children: [
              Gap(
                MediaQuery.of(context).viewPadding.top +
                    Dimensions.appBarHeight,
              ),
              Padding(
                padding: Paddings.horizontal16,
                child: Text(
                  '${package.name} ${package.version}',
                  style: ScaleTextStyles.title.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              if (package.description.isNotEmpty)
                Padding(
                  padding: Paddings.all16,
                  child: Text(
                    package.description,
                    style: ScaleTextStyles.text.apply(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              if (package.homepage != null)
                Padding(
                  padding: Paddings.all16,
                  child: InkWell(
                    child: Text(
                      package.homepage!,
                      style: ScaleTextStyles.text.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () async {
                      if (package.homepage != null &&
                          !await launchUrl(
                            Uri.parse(package.homepage!),
                          )) {
                        throw Exception(
                          'Could not launch ${package.homepage!}',
                        );
                      }
                    },
                  ),
                ),
              if (package.description.isNotEmpty || package.homepage != null)
                const Divider(),
              Padding(
                padding: Paddings.all16,
                child: Text(
                  _bodyText(),
                  style: ScaleTextStyles.text.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredScaleAppBar(
              title: localization.license_detail_screen_title,
              showClose: true,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
