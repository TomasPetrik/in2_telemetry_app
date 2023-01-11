import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scalesoft_app/extensions/date_extensions.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';

class ActionWidget extends StatelessWidget {
  const ActionWidget({
    super.key,
    required this.when,
    required this.activityType,
  });

  final DateTime when;
  final ActivityType activityType;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: activityType == ActivityType.active
            ? Constants.actionActiveWidgetHeight
            : Constants.actionPassiveWidgetHeight,
      ),
      height: activityType == ActivityType.active
          ? Constants.actionActiveWidgetHeight
          : Constants.actionPassiveWidgetHeight,
      margin: Paddings.horizontal16,
      padding: Paddings.all16,
      decoration: BoxDecoration(
        borderRadius: BorderRadii.radius16,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.onPrimaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/icon_wave_pulse.svg',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                Gaps.gap16,
                Text('Mereni krve ${activityType == ActivityType.passive ? 've ${when.getTimeShort()}' : ''}'),
                if (activityType == ActivityType.active) ...[
                  const Spacer(),
                  Text(when.getTimeShort()),
                ],
              ],
            ),
          ),
          if (activityType == ActivityType.active) ...[
            Gaps.gap16,
            HighlightedElevatedButton(
              label: context.locale.common_measure_now,
              buttonType: ButtonType.secondary,
            ),
          ]
        ],
      ),
    );
  }
}

enum ActivityType { active, passive }
