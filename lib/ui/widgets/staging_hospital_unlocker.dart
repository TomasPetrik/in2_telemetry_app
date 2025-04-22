import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scalesoft_app/data/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/widgets/hospital_unlock_dialog.dart';

class StagingHospitalUnlocker extends StatelessWidget {
  final Widget child;
  final ClickCounter counter = ClickCounter();

  final SettingsDbProvider _settingsDbProvider = getIt<SettingsDbProvider>();

  StagingHospitalUnlocker({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => counter.clicked(() => openDialog(context)),
      child: child,
    );
  }

  Future<void> openDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return const HospitalUnlockDialog();
      },
    );

    if (result == true) {
      await _settingsDbProvider.enableStagingHospitals();
    }
  }
}

class ClickCounter {
  static const int threshold = 7;

  int clickCount = 0;
  Timer? timer;

  void clicked(Function onSuccess) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 700), _timeout);

    clickCount++;
    if (clickCount >= threshold) {
      unlock(onSuccess);
    }
  }

  void _timeout() {
    timer?.cancel();
    timer = null;
  }

  void unlock(Function onSuccess) async {
    timer?.cancel();
    timer = null;
    clickCount = 0;

    onSuccess();
  }
}
