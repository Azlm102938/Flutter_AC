import 'package:flutter/material.dart';

class TemperatureDial extends StatelessWidget {
  final int temperature;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const TemperatureDial({
    super.key,
    required this.temperature,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$temperature°C',
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: temperature.toDouble(),
          min: 18,
          max: 30,
          divisions: 14,
          onChanged: enabled ? (v) => onChanged(v.round()) : null,
        ),
      ],
    );
  }
}
