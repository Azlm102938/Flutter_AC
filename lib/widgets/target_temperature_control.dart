import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TargetTemperatureControl extends StatefulWidget {
  final int temperature;
  final ValueChanged<int> onChanged;

  const TargetTemperatureControl({
    super.key,
    required this.temperature,
    required this.onChanged,
  });

  @override
  State<TargetTemperatureControl> createState() =>
      _TargetTemperatureControlState();
}

class _TargetTemperatureControlState extends State<TargetTemperatureControl> {
  final FlutterTts tts = FlutterTts();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    /// Setting bahasa Indonesia (optional)
    tts.setLanguage("id-ID");
    tts.setSpeechRate(0.5);
  }

  void _onTempChanged(int newTemp) {
    widget.onChanged(newTemp);

    /// 🔥 reset timer setiap perubahan
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _speak(newTemp);
    });
  }

  Future<void> _speak(int temp) async {
    await tts.stop();
    await tts.speak("Suhu diubah menjadi $temp derajat celcius");
  }

  void _increase() {
    if (widget.temperature < 30) {
      _onTempChanged(widget.temperature + 1);
    }
  }

  void _decrease() {
    if (widget.temperature > 18) {
      _onTempChanged(widget.temperature - 1);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canIncrease = widget.temperature < 30;
    final bool canDecrease = widget.temperature > 18;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlButton(
                icon: Icons.remove,
                onTap: _decrease,
                isEnabled: canDecrease,
              ),

              const SizedBox(width: 20),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  '${widget.temperature}°C',
                  key: ValueKey(widget.temperature),
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              _controlButton(
                icon: Icons.add,
                onTap: _increase,
                isEnabled: canIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.08),
          border: Border.all(
            color: isEnabled
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isEnabled ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}
