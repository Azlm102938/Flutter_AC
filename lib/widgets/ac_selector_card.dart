import 'package:flutter/material.dart';

class ACSelectorCard extends StatelessWidget {
  final List<String> acList;
  final String selectedAC;
  final ValueChanged<String> onChanged;

  const ACSelectorCard({
    super.key,
    required this.acList,
    required this.selectedAC,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: _glass(),
      child: Row(
        children: [
          const Icon(Icons.settings_remote, color: Colors.white70),
          const SizedBox(width: 10),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedAC,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),

                dropdownColor: const Color(0xFF203A43),

                // 🔥 INI YANG BIKIN SCROLL
                menuMaxHeight: 200,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),

                items: acList.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(e),
                    ),
                  );
                }).toList(),

                onChanged: (v) => onChanged(v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _glass() => BoxDecoration(
    color: Colors.white.withOpacity(0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.2)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
