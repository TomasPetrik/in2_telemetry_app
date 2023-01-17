import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/screens/beurer_screen.dart';
import 'package:scalesoft_app/ui/screens/omron_screen.dart';
import 'package:scalesoft_app/ui/screens/search_devices_screen.dart';

class SelectDeviceScreen extends StatelessWidget {
  const SelectDeviceScreen({super.key});

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
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const BeurerScreen(),
                  ),
                );
              },
              child: const Text('Beurer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const OmronScreen()),
                );
              },
              child: const Text('Omron'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const SearchDevicesScreen(),
                  ),
                );
              },
              child: const Text('Manual search'),
            ),
          ],
        ),
      ),
    );
  }
}
