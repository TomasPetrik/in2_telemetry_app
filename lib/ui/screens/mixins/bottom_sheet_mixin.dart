import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/dialogs/bottom_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/hospital_selection_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/planned_measurement_time_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/user_hospital_selection_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/user_selection_dialog.dart';
import 'package:scalesoft_app/ui/widgets/scale_time_picker.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

mixin BottomSheetMixin {
  Future<DailyTime?> showRestrictedTimePicker({
    required final BuildContext context,
    DailyTime? defaultTime,
    DailyTime? minTime,
    DailyTime? maxTime,
  }) async {
    final result = await showModalBottomSheet<DailyTime?>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.4,
          child: ScaleTimePicker(
            defaultTime: defaultTime,
            minTime: minTime,
            maxTime: maxTime,
          ),
        );
      },
    );
    return result;
  }

  Future<void> showDevAlreadyRegistered(
    BuildContext context,
    String deviceIdentifier,
  ) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomDialog.deviceAlreadyRegistered(
          context: context,
          macAddress: deviceIdentifier,
        );
      },
    );
  }

  Future<void> showServerError(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomDialog.serverError(context: context);
      },
    );
  }

  Future<bool?> showResultRemovalConfirmation({
    required final BuildContext context,
    required final MeasurementType measurementType,
  }) async {
    final result = await showModalBottomSheet<bool?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomDialog.resultConfirmationRemoval(
          context: context,
          measurementType: measurementType,
        );
      },
    );
    return result;
  }

  Future<bool?> showNotificationsSettings({
    required final BuildContext context,
  }) async {
    final result = await showModalBottomSheet<bool?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomDialog.openNotificationSettings(context: context);
      },
    );
    return result;
  }

  Future<bool?> showDeviceRemovalConfirmation({
    required final BuildContext context,
  }) async {
    final result = await showModalBottomSheet<bool?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomDialog.deviceConfirmationRemoval(context: context);
      },
    );
    return result;
  }

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
        return BottomDialog.accountConfirmationRemoval(
          context: context,
          accountName: accountName,
        );
      },
    );
    return result;
  }

  Future<bool?> showResetWhenTimeValuesConfirmation({
    required final BuildContext context,
  }) async {
    final result = await showModalBottomSheet<bool?>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomDialog.resetWhenTimeValues(
          context: context,
        );
      },
    );
    return result;
  }

  Future<PlannedPeriodSelection?> showPlannedMeasurementsSelector(
    final BuildContext context,
    final PlanWhenPeriod? whenPeriod,
    final Map<PlanWhenPeriod, int> measurements,
  ) async {
    final selected = await showModalBottomSheet<PlannedPeriodSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PlannedMeasurementTimeDialog(
          whenPeriod: whenPeriod ?? PlanWhenPeriod.today,
          measurements: measurements,
        );
      },
    );
    return selected;
  }

  Future<ResultPeriodSelection?> showResultsWhenSelector(
    final BuildContext context,
    final ResultsWhenPeriod? whenPeriod,
    final Map<ResultsWhenPeriod, int?> fulfillmentPlan,
    final bool canShowCalendar,
  ) async {
    final selected = await showModalBottomSheet<ResultPeriodSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ResultsTimeDialog(
          whenPeriod: whenPeriod ?? ResultsWhenPeriod.today,
          fulfillmentPlan: fulfillmentPlan,
          canShowCalendar: canShowCalendar,
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
    required final bool supportMultiUser,
  }) async {
    return await showModalBottomSheet<UserSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return UserHospitalSelectionDialog(
          supportMultiUser: supportMultiUser,
        );
      },
    ).then((userHospitalSelectionResult) async {
      SwitchUserResult switchUserResult;
      if (userHospitalSelectionResult?.action ==
          SwitchUserAction.selectedMultiUser) {
        switchUserResult = SwitchUserResult(activeMultiUser: true);
      } else if (userHospitalSelectionResult?.action ==
          SwitchUserAction.addUserAccount) {
        switchUserResult = SwitchUserResult(addNewUser: true);
      } else if (userHospitalSelectionResult?.action ==
          SwitchUserAction.selectedUser) {
        switchUserResult = SwitchUserResult(
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
          switchUserResult = SwitchUserResult(addNewUser: true);
        } else {
          switchUserResult =
              SwitchUserResult(selectedUser: userSelection?.selectedUser);
        }
      } else {
        switchUserResult = SwitchUserResult();
      }
      return switchUserResult;
    });
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
  selectedMultiUser,
}

class SwitchUserResult {
  UserAccount? selectedUser;
  bool? addNewUser;
  bool? activeMultiUser;

  SwitchUserResult({
    this.selectedUser,
    this.addNewUser,
    this.activeMultiUser,
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

class PlannedPeriodSelection {
  PlanWhenPeriod? selectedPeriod;
  bool? showCalendar;

  PlannedPeriodSelection({this.selectedPeriod, this.showCalendar})
      : assert(
          selectedPeriod != null || showCalendar != null,
          'Either selectedPeriod or showCalendar should be set !',
        );
}

class ResultPeriodSelection {
  ResultsWhenPeriod? selectedPeriod;
  bool? showCalendar;

  ResultPeriodSelection({this.selectedPeriod, this.showCalendar})
      : assert(
          selectedPeriod != null || showCalendar != null,
          'Either selectedPeriod or showCalendar should be set !',
        );
}
