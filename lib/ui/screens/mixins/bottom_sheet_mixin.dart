import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/hospital_selection_dialog.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';
import 'package:scalesoft_app/ui/widgets/measurement_time_dialog.dart';
import 'package:scalesoft_app/ui/widgets/user_selection_dialog.dart';

mixin BottomSheetMixin {
  Future<TypePeriodSelection?> showMeasurementTime(
    final BuildContext context,
    final PeriodType? selectedTime,
  ) async {
    final selected = await showModalBottomSheet<TypePeriodSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.padding16),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      builder: (context) {
        return MeasurementTimeDialog(selectedTime: selectedTime ?? PeriodType.today);
      },
    );
    return selected;
  }

  Future<UserAccount?> selectHospital({
    required final BuildContext context,
  }) async {
    final selectedUser = await showModalBottomSheet<UserAccount>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.padding16),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      builder: (context) {
        return const HospitalSelectionDialog();
      },
    );

    return selectedUser;
  }

  Future<UserAccount?> selectUserAccount({
    required final BuildContext context,
    required Hospital hospital,
    required List<UserAccount> userAccounts,
  }) async {
    final selectedUser = await showModalBottomSheet<UserAccount>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.padding16),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      builder: (context) {
        return UserSelectionDialog(hospital: hospital, userAccounts: userAccounts);
      },
    );

    return selectedUser;
  }
}

class TypePeriodSelection {
  PeriodType? selectedPeriod;
  bool? showCalendar;

  TypePeriodSelection({this.selectedPeriod, this.showCalendar})
      : assert(
          selectedPeriod != null || showCalendar != null,
          'Either selectedTime or showCalendar should be set !',
        );
}
