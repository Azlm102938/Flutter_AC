import 'package:flutter/material.dart';

class SwingControl extends StatelessWidget {
  final bool enabled;
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const SwingControl({
    super.key,
    required this.enabled,
    required this.isOn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _glass(),
      child: Row(
        children: [
          /// ICON
          Icon(
            Icons.swap_vert,
            size: 26,
            color: enabled ? Colors.white : Colors.white54,
          ),

          const SizedBox(width: 12),

          /// TEXT
          const Text(
            'Swing',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),

          const Spacer(),

          /// SWITCH
          Switch(value: isOn, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }

  BoxDecoration _glass() => BoxDecoration(
    color: Colors.white.withOpacity(0.12),
    borderRadius: BorderRadius.circular(24),
  );
}
