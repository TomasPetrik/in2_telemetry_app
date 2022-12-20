import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/measurement_info.dart';
import 'package:scalesoft_app/ui/screens/select_device_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/name_value_row.dart';

class MeasurementResultScreen extends StatelessWidget {
  const MeasurementResultScreen({
    super.key,
    required this.measurementInfo,
  });

  final MeasurementInfo measurementInfo;

  static const routeName = '/measurement-result-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Measurement Result')),
      body: Padding(
        padding: Paddings.all20,
        child: Column(
          children: [
            Column(
              children: [
                NameValueRow(name: 'Systolic', value: '${measurementInfo.systolic}'),
                Gaps.gap10,
                NameValueRow(name: 'Diastolic', value: '${measurementInfo.diastolic}'),
                Gaps.gap10,
                NameValueRow(name: 'Mean Arterial Pressure', value: '${measurementInfo.meanArterialPressure}'),
                Gaps.gap10,
                NameValueRow(name: 'Date Time', value: measurementInfo.timestamp),
                Gaps.gap10,
                NameValueRow(name: 'Pulse Rate', value: '${measurementInfo.pulseRate}'),
                Gaps.gap10,
                NameValueRow(name: 'User', value: '${measurementInfo.userId}'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => const SelectDeviceScreen()),
                );
              },
              child: const Text('Continue'),
            )
          ],
        ),
      ),
    );
  }
}
