import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/cubit/care_plan/care_plan_cubit.dart';
import 'package:scalesoft_app/cubit/care_plan/care_plan_cubit_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/painters/user_item_painter.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';
import 'package:scalesoft_app/ui/widgets/user_item_shape.dart';

class UserItem extends StatelessWidget {
  const UserItem({
    super.key,
    required this.user,
    this.userItemType,
    required this.hasNavigationIcon,
    this.showWarning,
  });

  final UserModel user;
  final UserItemType? userItemType;
  final bool hasNavigationIcon;
  final bool? showWarning;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarePlanCubit, CarePlanCubitState>(
      bloc: CarePlanCubit()..init(user.id),
      builder: (context, state) {
        return Padding(
          padding: Paddings.horizontal16,
          child: Row(
            children: [
              if (userItemType == UserItemType.middle || userItemType == UserItemType.last) ...[
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
                  label: user.fullName,
                  subLabel: _getCarePlansLabel(context, state.carePlans),
                  showWarning: showWarning == true && user.parentId == null,
                  hasNavigationIcon: hasNavigationIcon,
                  iconWidget: Padding(
                    padding: Paddings.all8,
                    child: Text(
                      '${user.firstNames[0][0]}${user.lastNames[0][0]}',
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
      },
    );
  }

  String? _getCarePlansLabel(BuildContext context, List<CarePlan> carePlans) {
    if (carePlans.isEmpty == true) return null;

    String label = localization.common_measurement_types(carePlans[0].activity.measurementType.name);

    if (carePlans.length > 1) {
      label += ' ${localization.common_plus_n_others(carePlans.length - 1)}';
    }
    return label;
  }
}
