import 'package:flutter/material.dart';

class AcModeControl extends StatelessWidget {
  final int mode;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const AcModeControl({
    super.key,
    required this.mode,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'AC Mode',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : Colors.white54,
          ),
        ),
        const SizedBox(height: 6),

        /// 🔥 ICON DINAMIS
        Icon(
          _icon,
          size: 32,
          color: enabled ? Colors.cyanAccent : Colors.white54,
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔽 MINUS (LOOP)
            _btn(Icons.remove, () {
              int newMode = (mode - 1) < 0 ? 3 : mode - 1;
              onChanged(newMode);
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
              int newMode = (mode + 1) > 3 ? 0 : mode + 1;
              onChanged(newMode);
            }),
          ],
        ),
      ],
    );
  }

  /// 🔥 LABEL
  String get _label {
    switch (mode) {
      case 0:
        return 'AUTO';
      case 1:
        return 'NORMAL';
      case 2:
        return 'DRY';
      case 3:
        return 'FAN';
      default:
        return 'AUTO';
    }
  }

  /// 🔥 ICON PER MODE
  IconData get _icon {
    switch (mode) {
      case 0:
        return Icons.autorenew; // AUTO
      case 1:
        return Icons.ac_unit; // NORMAL
      case 2:
        return Icons.water_drop; // DRY
      case 3:
        return Icons.air; // FAN
      default:
        return Icons.autorenew;
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
