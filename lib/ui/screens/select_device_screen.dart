import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/screens/beurer_screen.dart';
import 'package:scalesoft_app/ui/screens/omron_screen.dart';
import 'package:scalesoft_app/ui/screens/search_devices_screen.dart';

class SelectDeviceScreen extends StatelessWidget {
  const SelectDeviceScreen({super.key});

  static const routeName = '/select-device-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Device')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, BeurerScreen.routeName);
              },
              child: const Text('Beurer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, OmronScreen.routeName);
              },
              child: const Text('Omron'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, SearchDevicesScreen.routeName);
              },
              child: const Text('Manual search'),
            ),
          ],
        ),
      ),
    );
  }
}
