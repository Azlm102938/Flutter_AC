import 'package:flutter/material.dart';

class PowerFAB extends StatelessWidget {
  final bool isOn;
  final VoidCallback onToggle;

  const PowerFAB({super.key, required this.isOn, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: FloatingActionButton(
        backgroundColor: isOn ? Colors.redAccent : Colors.greenAccent,
        onPressed: onToggle,
        child: Icon(isOn ? Icons.power_settings_new : Icons.power, size: 36),
      ),
    );
  }
}
