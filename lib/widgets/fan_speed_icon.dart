import 'package:flutter/material.dart';

class FanSpeedControl extends StatelessWidget {
  final int speed;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const FanSpeedControl({
    super.key,
    required this.speed,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Fan Speed',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : Colors.white54,
          ),
        ),

        const SizedBox(height: 6),

        /// 🔥 ICON DINAMIS
        Icon(_icon, size: 32, color: enabled ? _color : Colors.white54),

        const SizedBox(height: 8),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔽 MINUS (LOOP)
            _btn(Icons.remove, () {
              int newSpeed = (speed - 1) < 0 ? 3 : speed - 1;
              onChanged(newSpeed);
            }),

            const SizedBox(width: 8),

            /// LABEL
            Text(
              _label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 8),

            /// 🔼 PLUS (LOOP)
            _btn(Icons.add, () {
              int newSpeed = (speed + 1) > 3 ? 0 : speed + 1;
              onChanged(newSpeed);
            }),
          ],
        ),
      ],
    );
  }

  /// 🔥 LABEL
  String get _label {
    switch (speed) {
      case 0:
        return 'AUTO';
      case 1:
        return 'LOW';
      case 2:
        return 'MEDIUM';
      case 3:
        return 'HIGH';
      default:
        return 'AUTO';
    }
  }

  /// 🔥 ICON PER SPEED
  IconData get _icon {
    switch (speed) {
      case 0:
        return Icons.autorenew; // AUTO
      case 1:
        return Icons.air; // LOW
      case 2:
        return Icons.wind_power; // MEDIUM
      case 3:
        return Icons.tornado; // HIGH (visual kuat)
      default:
        return Icons.autorenew;
    }
  }

  /// 🔥 WARNA BIAR LEBIH HIDUP
  Color get _color {
    switch (speed) {
      case 0:
        return Colors.blueAccent;
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white24,
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
