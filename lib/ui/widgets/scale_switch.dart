import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScaleSwitch extends StatefulWidget {
  const ScaleSwitch({
    super.key,
    required this.onChanged,
    required this.value,
  });

  final ValueChanged<bool>? onChanged;
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

  @override void didUpdateWidget(covariant ScaleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.value != widget.value){
      value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      trackColor: Theme.of(context).colorScheme.tertiary,
      activeColor: Theme.of(context).colorScheme.primary,
      thumbColor: Theme.of(context).colorScheme.background,
      onChanged: widget.onChanged == null
          ? null
          : (newValue) {
              widget.onChanged!(newValue);
              setState(() {
                value = newValue;
              });
            },
      value: value,
    );
  }
}
