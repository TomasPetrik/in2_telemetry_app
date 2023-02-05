import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/dialogs/confimation_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/device_selector_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/hospital_selection_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/measurement_time_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/user_hospital_selection_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/user_selection_dialog.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

mixin BottomSheetMixin {
  Future<bool?> showAccounRemovalConfirmation({
    required final BuildContext context,
    required final String accountName,
  }) async {
    final result = await showModalBottomSheet<bool?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ConfirmationDialog.accountRemoval(
          context: context,
          accountName: accountName,
        );
      },
    );
    return result;
  }

  Future<TypePeriodSelection?> showWhenSelector(
    final BuildContext context,
    final WhenPeriod? whenPeriod,
    final Map<WhenPeriod, int> measurements,
  ) async {
    final selected = await showModalBottomSheet<TypePeriodSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MeasurementTimeDialog(
          whenPeriod: whenPeriod ?? WhenPeriod.today,
          measurements: measurements,
        );
      },
    );
    return selected;
  }

  Future<UserSelection?> selectHospital({
    required final BuildContext context,
  }) async {
    final selectedHospitalResult = await showModalBottomSheet<UserSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 1.0,
          child: Padding(
            padding: EdgeInsets.only(
              top: 44,
            ),
            child: HospitalSelectionDialog(),
          ),
        );
      },
    );

    return selectedHospitalResult;
  }

  Future<SwitchUserResult?> switchUser({
    required final BuildContext context,
  }) async {
    final userHospitalSelectionResult =
        await showModalBottomSheet<UserSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const UserHospitalSelectionDialog();
      },
    );

    if (userHospitalSelectionResult?.action ==
        SwitchUserAction.addUserAccount) {
      return SwitchUserResult(addNewUser: true);
    } else if (userHospitalSelectionResult?.action ==
        SwitchUserAction.selectedUser) {
      return SwitchUserResult(
        selectedUser: userHospitalSelectionResult!.selectedUser,
      );
    } else if (userHospitalSelectionResult?.action ==
        SwitchUserAction.selectedHospital) {
      final userSelection = await _selectUserFromHospital(
        context: context,
        hospital: userHospitalSelectionResult!.selectedHospital!,
        userAccounts: userHospitalSelectionResult.hospitalUsers!,
      );

      if (userSelection?.action == SwitchUserAction.addUserAccount) {
        return SwitchUserResult(addNewUser: true);
      } else {
        return SwitchUserResult(selectedUser: userSelection?.selectedUser);
      }
    } else {
      return SwitchUserResult();
    }
  }

  Future<UserSelection?> _selectUserFromHospital({
    required final BuildContext context,
    required Hospital hospital,
    required List<UserAccount> userAccounts,
  }) async {
    final userSelectionResult = await showModalBottomSheet<UserSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return UserSelectionDialog(
          hospital: hospital,
          userAccounts: userAccounts,
        );
      },
    );

    return userSelectionResult;
  }

  Future<bool?> showDeviceSelector({
    required final BuildContext context,
    required final String userId,
    final MeasurementType? selectedMeasurementType,
    final Set<MeasurementType>? allMeasurementTypes,
  }) async {
    final result = await showModalBottomSheet<bool?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DeviceSelectorDialog(
          userId: userId,
          selectedMeasurementType: selectedMeasurementType,
          allMeasurementTypes: allMeasurementTypes,
        );
      },
    );
    return result;
  }
}

class DeviceSelectionResult {
  bool? manualMeasurement;

  DeviceSelectionResult({
    this.manualMeasurement,
  });
}

enum SwitchUserAction {
  addUserAccount,
  selectedUser,
  selectedHospital,
}

class SwitchUserResult {
  UserAccount? selectedUser;
  bool? addNewUser;

  SwitchUserResult({
    this.selectedUser,
    this.addNewUser,
  });
}

class UserSelection {
  UserAccount? selectedUser;
  Hospital? selectedHospital;
  List<UserAccount>? hospitalUsers;
  SwitchUserAction action;

  UserSelection({
    required this.action,
    this.selectedUser,
    this.selectedHospital,
    this.hospitalUsers,
  });
}

class TypePeriodSelection {
  WhenPeriod? selectedPeriod;
  bool? showCalendar;

  TypePeriodSelection({this.selectedPeriod, this.showCalendar})
      : assert(
          selectedPeriod != null || showCalendar != null,
          'Either selectedTime or showCalendar should be set !',
        );
}
