import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SttButton extends StatefulWidget {
  final ValueChanged<String> onResult;

  const SttButton({super.key, required this.onResult});

  @override
  State<SttButton> createState() => _SttButtonState();
}

class _SttButtonState extends State<SttButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _toggleListening() async {
    print("MIC PRESSED");

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print("STATUS: $status");

          if (status == "notListening" || status == "done") {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print("ERROR: $error");

          if (_isListening) {
            setState(() => _isListening = false);
          }
        },
      );

      print("AVAILABLE: $available");

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          localeId: "id_ID", // bisa tetap deteksi English juga
          listenFor: const Duration(seconds: 16), // 🔥 maksimal 16 detik
          pauseFor: const Duration(seconds: 5), // 🔥 berhenti jika diam 5 detik
          listenMode: stt.ListenMode.confirmation,
          onResult: (result) {
            print("RESULT: ${result.recognizedWords}");

            if (result.finalResult) {
              widget.onResult(result.recognizedWords);

              // 🔥 stop mic after 1 command
              _speech.stop();

              setState(() => _isListening = false);
            }
          },
        );
      } else {
        print("Speech not available");
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      print("STOPPED");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "stt_button",
      backgroundColor: _isListening ? Colors.red : Colors.blue,
      onPressed: _toggleListening,
      child: Icon(_isListening ? Icons.mic : Icons.mic_none),
    );
  }
}
