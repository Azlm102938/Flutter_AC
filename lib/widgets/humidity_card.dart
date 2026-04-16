import 'package:flutter/material.dart';

class HumidityCard extends StatelessWidget {
  final int humidity;

  const HumidityCard({super.key, required this.humidity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glass(),
      child: Column(
        children: [
          const Icon(Icons.water_drop, size: 30),
          const SizedBox(height: 8),
          Text('$humidity%', style: const TextStyle(fontSize: 24)),
          const Text('Humidity'),
        ],
      ),
    );
  }

  BoxDecoration _glass() => BoxDecoration(
    color: Colors.white.withOpacity(0.12),
    borderRadius: BorderRadius.circular(24),
  );
}
