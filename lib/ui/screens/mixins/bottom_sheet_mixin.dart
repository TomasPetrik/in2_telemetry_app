import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/widgets/confimation_dialog.dart';
import 'package:scalesoft_app/ui/widgets/hospital_selection_dialog.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';
import 'package:scalesoft_app/ui/widgets/measurement_time_dialog.dart';
import 'package:scalesoft_app/ui/widgets/user_hospital_selection_dialog.dart';
import 'package:scalesoft_app/ui/widgets/user_selection_dialog.dart';

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

  Future<TypePeriodSelection?> showMeasurementTime(
    final BuildContext context,
    final PeriodType? selectedTime,
  ) async {
    final selected = await showModalBottomSheet<TypePeriodSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MeasurementTimeDialog(
          selectedTime: selectedTime ?? PeriodType.today,
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

      if (userSelection!.action == SwitchUserAction.addUserAccount) {
        return SwitchUserResult(addNewUser: true);
      } else {
        return SwitchUserResult(selectedUser: userSelection.selectedUser);
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
  PeriodType? selectedPeriod;
  bool? showCalendar;

  TypePeriodSelection({this.selectedPeriod, this.showCalendar})
      : assert(
          selectedPeriod != null || showCalendar != null,
          'Either selectedTime or showCalendar should be set !',
        );
}
