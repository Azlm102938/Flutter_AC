import 'package:flutter/material.dart';

class EnvironmentCard extends StatelessWidget {
  final int temperature;
  final int humidity;
  final bool enabled;

  const EnvironmentCard({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16), // 👈 dorong ke kiri
              child: Align(
                alignment: Alignment.centerLeft,
                child: _item(
                  icon: Icons.thermostat,
                  value: enabled ? '$temperature°C' : '--',
                  label: 'Room Temp',
                  color: Colors.orangeAccent,
                ),
              ),
            ),
          ),

          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 44), // 👈 dorong ke kanan
              child: Align(
                alignment: Alignment.centerRight,
                child: _item(
                  icon: Icons.water_drop,
                  value: enabled ? '$humidity%' : '--',
                  label: 'Humidity',
                  color: Colors.cyanAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min, // 🔥 penting
      mainAxisAlignment: MainAxisAlignment.start, // 🔥 FIX DISINI
      children: [
        Icon(icon, size: 40, color: color),

        const SizedBox(width: 5),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
