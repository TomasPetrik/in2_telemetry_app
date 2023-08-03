
import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/painters/user_item_painter.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';
import 'package:scalesoft_app/ui/widgets/user_item_shape.dart';

class UserItem extends StatelessWidget {
  const UserItem({
    super.key,
    required this.userAccount,
    this.userItemType,
    required this.hasNavigationIcon,
    this.showWarning,
  });

  final UserAccount userAccount;
  final UserItemType? userItemType;
  final bool hasNavigationIcon;
  final bool? showWarning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Paddings.horizontal16,
      child: Row(
        children: [
          if (userItemType == UserItemType.middle ||
              userItemType == UserItemType.last) ...[
            Gaps.gap16,
            Stack(
              children: [
                SizedBox(
                  height: 64,
                  child: UserItemShape(userItemType: userItemType!),
                ),
              ],
            ),
          ],
          Expanded(
            child: SettingsItem(
              label: userAccount.user.fullName,
              subLabel: _getCarePlansLabel(context, userAccount),
              showWarning: showWarning == true && userAccount.parentId == null,
              hasNavigationIcon: hasNavigationIcon,
              iconWidget: Padding(
                padding: Paddings.all8,
                child: Text(
                  '${userAccount.user.firstNames[0][0]}${userAccount.user.lastNames[0][0]}',
                  style: ScaleTextStyles.title.apply(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getCarePlansLabel(BuildContext context, UserAccount userAccount) {
    final carePlans = userAccount.carePlans;
    if (carePlans?.isEmpty == true) return null;

    String label = localization
        .common_measurement_types(carePlans![0].activity.measurementType.name);

    if (carePlans.length > 1) {
      label += ' ${localization.common_plus_n_others(carePlans.length - 1)}';
    }
    return label;
  }
}
