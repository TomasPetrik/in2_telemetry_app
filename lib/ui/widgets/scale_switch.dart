import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScaleSwitch extends StatefulWidget {
  const ScaleSwitch({
    super.key,
    required this.onChanged,
    required this.value,
  });

  final Function(bool turnedOn) onChanged;
  final bool value;

  @override
  State<ScaleSwitch> createState() => _ScaleSwitchState();
}

class _ScaleSwitchState extends State<ScaleSwitch> {
  late bool value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      trackColor: Theme.of(context).colorScheme.tertiary,
      activeColor: Theme.of(context).colorScheme.primary,
      thumbColor: Theme.of(context).colorScheme.background,
      onChanged: (newValue) {
        widget.onChanged.call(newValue);
        setState(() {
          value = newValue;
        });
      },
      value: value,
    );
  }
}
