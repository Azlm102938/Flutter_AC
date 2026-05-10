// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// /// =======================================================
// /// RED    = loading / processing
// /// GREEN  = idle standby wakeword
// /// ORANGE = speaking
// /// BLUE   = listening command
// ///
// /// FLOW:
// /// idle forever
// /// -> "hei ac"
// /// -> TTS "Ya?"
// /// -> wait command (timeout)
// /// -> execute
// /// -> back idle forever
// /// =======================================================

// enum VoiceState { loading, idle, speaking, command }

// class SttButton extends StatefulWidget {
//   final Future<void> Function(String text) onResult;

//   const SttButton({super.key, required this.onResult});

//   @override
//   State<SttButton> createState() => _SttButtonState();
// }

// class _SttButtonState extends State<SttButton> {
//   late stt.SpeechToText _speech;
//   final FlutterTts _tts = FlutterTts();

//   bool _engineReady = false;
//   bool _disposed = false;

//   bool _isListening = false;
//   bool _isRestarting = false;
//   bool _isExecuting = false;
//   bool _isWaking = false;
//   bool _blockIdleRestart = false;

//   VoiceState _state = VoiceState.loading;

//   Timer? _commandTimeout;
//   Timer? _finalizeTimer;

//   String _liveText = "";

//   /// =======================================================
//   /// INIT
//   /// =======================================================
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _boot();
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     _commandTimeout?.cancel();
//     _finalizeTimer?.cancel();
//     _speech.stop();
//     _tts.stop();
//     super.dispose();
//   }

//   Future<void> _boot() async {
//     await _tts.setLanguage("id-ID");
//     await _tts.setSpeechRate(0.45);
//     await _tts.awaitSpeakCompletion(true);

//     _engineReady = await _speech.initialize(
//       onStatus: _onStatus,
//       onError: _onError,
//       debugLogging: false,
//     );

//     await Future.delayed(const Duration(milliseconds: 500));

//     _startIdleMode();
//   }

//   /// =======================================================
//   /// CALLBACK
//   /// =======================================================
//   void _onStatus(String status) {
//     print("STATUS: $status");

//     if (_disposed) return;

//     if (status == "listening") {
//       _isListening = true;
//       return;
//     }

//     if (status == "done" || status == "notListening") {
//       _isListening = false;

//       /// idle mode restart
//       if (_state == VoiceState.idle && !_blockIdleRestart) {
//         _restartIdleSafe();
//       }

//       /// command mode selesai -> execute walau finalResult ga keluar
//       if (_state == VoiceState.command && !_isExecuting) {
//         _finalizeTimer?.cancel();

//         _finalizeTimer = Timer(const Duration(milliseconds: 450), () async {
//           if (_liveText.trim().isNotEmpty) {
//             await _execute(_liveText.trim());
//           } else {
//             await _returnIdle();
//           }
//         });
//       }
//     }
//   }

//   void _onError(dynamic error) {
//     print("ERROR: ${error.errorMsg}");

//     _isListening = false;

//     if (_disposed) return;

//     _restartIdleSafe();
//   }

//   /// =======================================================
//   /// UI
//   /// =======================================================
//   void _setState(VoiceState s) {
//     _state = s;
//     if (mounted) setState(() {});
//   }

//   /// =======================================================
//   /// SAFE RESTART
//   /// =======================================================
//   void _restartIdleSafe() {
//     if (_disposed) return;
//     if (_isRestarting) return;
//     if (_state != VoiceState.idle) return;

//     _isRestarting = true;

//     Future.delayed(const Duration(milliseconds: 900), () async {
//       if (_disposed) return;

//       _isRestarting = false;
//       await _startIdleMode();
//     });
//   }

//   /// =======================================================
//   /// IDLE MODE
//   /// =======================================================
//   Future<void> _startIdleMode() async {
//     if (_disposed) return;
//     if (!_engineReady) return;
//     if (_isListening) return;
//     if (_isExecuting) return;

//     await _speech.stop();

//     _setState(VoiceState.idle);

//     print("IDLE MODE START");

//     await _speech.listen(
//       localeId: "id_ID",
//       partialResults: false,
//       cancelOnError: false,
//       listenMode: stt.ListenMode.confirmation,
//       listenFor: const Duration(minutes: 30),
//       pauseFor: const Duration(seconds: 8),
//       onResult: (result) async {
//         final text = result.recognizedWords.toLowerCase().trim();

//         if (text.isEmpty) return;

//         print("IDLE HEARD: $text");

//         if (_isWakeWord(text)) {
//           _blockIdleRestart = true;

//           await _speech.stop();
//           await _wakeSequence();
//           return;
//         }
//       },
//     );
//   }

//   /// =======================================================
//   /// WAKE SEQUENCE
//   /// =======================================================
//   Future<void> _wakeSequence() async {
//     await _tts.stop();

//     _isListening = false; // reset status lama
//     await _speech.stop();

//     await _speak("Ya?");
//     await Future.delayed(const Duration(milliseconds: 300));

//     _isListening = false; // reset lagi setelah TTS
//     _blockIdleRestart = false;

//     await _startCommandMode();
//   }

//   /// =======================================================
//   /// SPEAK
//   /// =======================================================
//   Future<void> _speak(String text) async {
//     _setState(VoiceState.speaking);

//     await _tts.stop();
//     await _tts.speak(text);
//   }

//   /// =======================================================
//   /// COMMAND MODE
//   /// =======================================================
//   Future<void> _startCommandMode() async {
//     if (_disposed) return;
//     if (_isListening && _state == VoiceState.command) return;
//     if (_isExecuting) return;

//     _setState(VoiceState.command);

//     _liveText = "";

//     _commandTimeout?.cancel();
//     _finalizeTimer?.cancel();

//     _commandTimeout = Timer(const Duration(seconds: 12), () {
//       _returnIdle();
//     });

//     print("COMMAND MODE");

//     await _speech.listen(
//       localeId: "id_ID",
//       partialResults: true,
//       cancelOnError: false,
//       listenMode: stt.ListenMode.dictation,
//       listenFor: const Duration(seconds: 10),
//       pauseFor: const Duration(seconds: 4),
//       onResult: (result) async {
//         String text = result.recognizedWords.toLowerCase().trim();

//         if (text.isEmpty) return;

//         text = _cleanText(text);
//         text = _autoCorrect(text);

//         if (text.isEmpty) return;

//         if (text.length >= _liveText.length) {
//           _liveText = text;
//         }

//         print("LIVE COMMAND: $_liveText");

//         if (result.finalResult) {
//           _finalizeTimer?.cancel();

//           _finalizeTimer = Timer(const Duration(milliseconds: 350), () async {
//             if (_liveText.isNotEmpty) {
//               await _execute(_liveText);
//             }
//           });
//         }
//       },
//     );
//   }

//   /// =======================================================
//   /// EXECUTE
//   /// =======================================================
//   Future<void> _execute(String cmd) async {
//     if (_isExecuting) return;

//     _isExecuting = true;

//     print("FINAL COMMAND: $cmd");

//     _commandTimeout?.cancel();
//     _finalizeTimer?.cancel();

//     _setState(VoiceState.loading);

//     await _speech.stop();

//     await widget.onResult(cmd);

//     await Future.delayed(const Duration(milliseconds: 250));

//     _isExecuting = false;

//     _returnIdle();
//   }

//   /// =======================================================
//   /// RETURN IDLE
//   /// =======================================================
//   Future<void> _returnIdle() async {
//     if (_disposed) return;

//     _commandTimeout?.cancel();
//     _finalizeTimer?.cancel();

//     await _speech.stop();

//     await Future.delayed(const Duration(milliseconds: 500));

//     _startIdleMode();
//   }

//   /// =======================================================
//   /// BUTTON PRESS
//   /// =======================================================
//   Future<void> _manualPressed() async {
//     if (_disposed) return;
//     if (_isExecuting) return;

//     print("BUTTON PRESSED");

//     _commandTimeout?.cancel();
//     _finalizeTimer?.cancel();

//     _liveText = "";

//     _isListening = false;

//     await _speech.stop();
//     await _tts.stop();

//     _setState(VoiceState.loading);

//     /// kasih waktu plugin release mic lama
//     await Future.delayed(const Duration(milliseconds: 700));

//     if (_disposed) return;

//     await _startCommandMode();
//   }

//   /// =======================================================
//   /// HELPERS
//   /// =======================================================
//   bool _isWakeWord(String text) {
//     const keys = [
//       "hei ac",
//       "hey ac",
//       "hai ac",
//       "halo ac",
//       "hei asi",
//       "hey asi",
//       "hai asi",
//       "halo asi",
//     ];

//     return keys.any((e) => text.contains(e));
//   }

//   String _cleanText(String text) {
//     return text
//         .replaceAll("ya", "")
//         .replaceAll("iya", "")
//         .replaceAll("oke", "")
//         .replaceAll("ok", "")
//         .trim();
//   }

//   String _autoCorrect(String text) {
//     final fixes = {
//       "asi": "ac",
//       "asih": "ac",
//       "esi": "ac",
//       "ace": "ac",
//       "nla": "nyala",

//       "kode": "mode",
//     };

//     fixes.forEach((k, v) {
//       text = text.replaceAll(k, v);
//     });

//     return text.trim();
//   }

//   /// =======================================================
//   /// UI
//   /// =======================================================
//   @override
//   Widget build(BuildContext context) {
//     Color color;
//     IconData icon;

//     switch (_state) {
//       case VoiceState.loading:
//         color = Colors.red;
//         icon = Icons.hourglass_top;
//         break;

//       case VoiceState.idle:
//         color = Colors.green;
//         icon = Icons.mic;
//         break;

//       case VoiceState.speaking:
//         color = Colors.orange;
//         icon = Icons.volume_up;
//         break;

//       case VoiceState.command:
//         color = Colors.blue;
//         icon = Icons.graphic_eq;
//         break;
//     }

//     return FloatingActionButton(
//       heroTag: "voice_btn",
//       onPressed: _manualPressed,
//       backgroundColor: color,
//       child: Icon(icon, size: 30),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// =======================================================
/// STATE WARNA:
/// RED    = loading / processing
/// GREEN  = idle standby wakeword
/// ORANGE = speaking (TTS)
/// BLUE   = listening command
///
/// FLOW:
/// idle (listen wakeword forever, restart tiap 90 detik)
/// -> detect wakeword
/// -> TTS "Ya?"
/// -> listen command (timeout 12 detik)
/// -> execute command
/// -> kembali idle
/// =======================================================

enum VoiceState { loading, idle, speaking, command }

class SttButton extends StatefulWidget {
  final Future<void> Function(String text) onResult;

  const SttButton({super.key, required this.onResult});

  @override
  State<SttButton> createState() => _SttButtonState();
}

class _SttButtonState extends State<SttButton> {
  late stt.SpeechToText _speech;
  final FlutterTts _tts = FlutterTts();

  bool _engineReady = false;
  bool _disposed = false;

  bool _isListening = false; // plugin sedang listen (dari onStatus)
  bool _isActuallyListening = false; // STT benar-benar siap terima suara
  bool _isRestarting = false;
  bool _isExecuting = false;
  bool _blockIdleRestart = false;

  VoiceState _voiceState = VoiceState.loading;

  Timer? _commandTimeout;
  Timer? _finalizeTimer;
  Timer? _idleRestartTimer;

  String _liveText = "";

  // =======================================================
  // INIT
  // =======================================================
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _boot();
  }

  @override
  void dispose() {
    _disposed = true;
    _commandTimeout?.cancel();
    _finalizeTimer?.cancel();
    _idleRestartTimer?.cancel();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _boot() async {
    await _tts.setLanguage("id-ID");
    await _tts.setSpeechRate(0.45);
    await _tts.awaitSpeakCompletion(true);

    _engineReady = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
      debugLogging: false,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    _startIdleMode();
  }

  // =======================================================
  // CALLBACK: STATUS
  // =======================================================
  void _onStatus(String status) {
    print("STT STATUS: $status");

    if (_disposed) return;

    if (status == "listening") {
      _isListening = true;

      // Engine benar-benar siap → update UI supaya user tahu boleh bicara
      if (!_isActuallyListening) {
        _isActuallyListening = true;
        if (mounted) setState(() {});
        print("STT READY: mic aktif, user boleh bicara");
      }
      return;
    }

    if (status == "done" || status == "notListening") {
      _isListening = false;
      _isActuallyListening = false;

      if (_voiceState == VoiceState.idle && !_blockIdleRestart) {
        _scheduleIdleRestart();
      }

      // Command mode selesai karena mic stop sendiri → execute
      if (_voiceState == VoiceState.command && !_isExecuting) {
        _finalizeTimer?.cancel();
        _finalizeTimer = Timer(const Duration(milliseconds: 450), () async {
          if (!_disposed && _liveText.trim().isNotEmpty) {
            await _execute(_liveText.trim());
          } else {
            await _returnIdle();
          }
        });
      }
    }
  }

  // =======================================================
  // CALLBACK: ERROR
  // =======================================================
  void _onError(dynamic error) {
    print("STT ERROR: ${error.errorMsg}");

    _isListening = false;

    if (_disposed) return;

    // Hanya restart idle jika memang di idle mode
    if (_voiceState == VoiceState.idle) {
      _scheduleIdleRestart();
    }
  }

  // =======================================================
  // SET STATE HELPER
  // =======================================================
  void _setVoiceState(VoiceState s) {
    _voiceState = s;
    if (mounted) setState(() {});
  }

  // =======================================================
  // IDLE RESTART — dijadwalkan, bukan langsung
  // =======================================================
  void _scheduleIdleRestart() {
    if (_disposed) return;
    if (_isRestarting) return;
    if (_voiceState != VoiceState.idle) return;

    _isRestarting = true;

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (_disposed) return;
      _isRestarting = false;
      await _startIdleMode();
    });
  }

  // =======================================================
  // IDLE MODE — listen wakeword
  // Restart tiap 90 detik supaya plugin tidak stuck
  // =======================================================
  Future<void> _startIdleMode() async {
    if (_disposed) return;
    if (!_engineReady) return;
    if (_isListening) return;
    if (_isExecuting) return;
    if (_blockIdleRestart) return;

    _idleRestartTimer?.cancel();
    await _speech.stop();
    await Future.delayed(const Duration(milliseconds: 200));

    _setVoiceState(VoiceState.idle);
    _liveText = "";

    print("IDLE MODE: listening wakeword...");

    await _speech.listen(
      localeId: "id_ID",
      partialResults: false,
      cancelOnError: false,
      listenMode: stt.ListenMode.confirmation,
      listenFor: const Duration(
        seconds: 90,
      ), // max 90 detik lalu restart otomatis
      pauseFor: const Duration(seconds: 6),
      onResult: (result) async {
        if (_disposed) return;
        if (_voiceState != VoiceState.idle) return;

        final text = result.recognizedWords.toLowerCase().trim();

        if (text.isEmpty) return;

        print("IDLE HEARD: $text");

        if (_isWakeWord(text)) {
          _blockIdleRestart = true;
          _idleRestartTimer?.cancel();

          await _speech.stop();
          await _wakeSequence();
        }
      },
    );

    // Restart idle setelah 90 detik (jaga-jaga jika onStatus tidak terpicu)
    _idleRestartTimer = Timer(const Duration(seconds: 95), () {
      if (_disposed) return;
      if (_voiceState == VoiceState.idle && !_blockIdleRestart) {
        print("IDLE AUTO-RESTART");
        _isRestarting = false;
        _isListening = false;
        _startIdleMode();
      }
    });
  }

  // =======================================================
  // WAKE SEQUENCE
  // =======================================================
  Future<void> _wakeSequence() async {
    if (_disposed) return;

    await _tts.stop();
    await _speech.stop();

    _isListening = false;

    await _speak("Ya?");

    await Future.delayed(const Duration(milliseconds: 300));

    _isListening = false;
    _blockIdleRestart = false;

    await _startCommandMode();
  }

  // =======================================================
  // TTS SPEAK
  // =======================================================
  Future<void> _speak(String text) async {
    _setVoiceState(VoiceState.speaking);
    await _tts.stop();
    await _tts.speak(text);
  }

  // =======================================================
  // COMMAND MODE — listen perintah
  // =======================================================
  Future<void> _startCommandMode() async {
    if (_disposed) return;
    if (_isExecuting) return;

    _setVoiceState(VoiceState.command);

    _liveText = "";

    _commandTimeout?.cancel();
    _finalizeTimer?.cancel();

    // Timeout 12 detik jika user tidak bicara sama sekali
    _commandTimeout = Timer(const Duration(seconds: 12), () {
      if (!_disposed) _returnIdle();
    });

    print("COMMAND MODE: listening...");

    await _speech.listen(
      localeId: "id_ID",
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) async {
        if (_disposed) return;
        if (_isExecuting) return;

        String text = result.recognizedWords.toLowerCase().trim();

        if (text.isEmpty) return;

        text = _cleanText(text);

        if (text.isEmpty) return;

        // Selalu ambil teks terpanjang (paling lengkap)
        if (text.length >= _liveText.length) {
          _liveText = text;
        }

        print("LIVE CMD: $_liveText | final=${result.finalResult}");

        if (result.finalResult) {
          // Hanya satu timer yang berjalan, cancel yang lama dulu
          _finalizeTimer?.cancel();
          _finalizeTimer = Timer(const Duration(milliseconds: 300), () async {
            if (!_disposed && _liveText.isNotEmpty && !_isExecuting) {
              await _execute(_liveText);
            }
          });
        }
      },
    );
  }

  // =======================================================
  // EXECUTE
  // =======================================================
  Future<void> _execute(String cmd) async {
    if (_isExecuting) return; // guard double-execute

    _isExecuting = true;

    _commandTimeout?.cancel();
    _finalizeTimer?.cancel();

    print("EXECUTE: $cmd");

    _setVoiceState(VoiceState.loading);

    await _speech.stop();

    await widget.onResult(cmd);

    await Future.delayed(const Duration(milliseconds: 250));

    _isExecuting = false;

    await _returnIdle();
  }

  // =======================================================
  // RETURN IDLE
  // =======================================================
  Future<void> _returnIdle() async {
    if (_disposed) return;

    _commandTimeout?.cancel();
    _finalizeTimer?.cancel();

    _blockIdleRestart = false;
    _isListening = false;

    await _speech.stop();

    await Future.delayed(const Duration(milliseconds: 500));

    await _startIdleMode();
  }

  // =======================================================
  // MANUAL BUTTON PRESS
  // =======================================================
  Future<void> _manualPressed() async {
    if (_disposed) return;
    if (_isExecuting) return;

    print("MANUAL BUTTON PRESSED");

    _commandTimeout?.cancel();
    _finalizeTimer?.cancel();
    _idleRestartTimer?.cancel();

    _liveText = "";
    _isListening = false;
    _blockIdleRestart = true;

    await _speech.stop();
    await _tts.stop();

    _setVoiceState(VoiceState.loading);

    // Beri waktu plugin release mic
    await Future.delayed(const Duration(milliseconds: 600));

    if (_disposed) return;

    await _speak("Silakan bicara");
    await _startCommandMode();
  }

  // =======================================================
  // WAKE WORD DETECTION
  // Diperluas + toleran terhadap noise/typo STT
  // =======================================================
  bool _isWakeWord(String text) {
    // Exact phrases yang umum diucapkan
    const phrases = [
      // "hei ac" variants
      "hei ac", "hey ac", "hai ac", "halo ac",
      "he ac", "hi ac",

      // STT sering salah dengar "ac" jadi ini:
      "hei asi", "hey asi", "hai asi",
      "hei ase", "hey ase", "hai ase",
      "hei ace", "hey ace", "hai ace",
      "hei ah", "hey ah",

      // Kadang "hei" jadi "he" atau "a"
      "he asi", "hi asi",
      "a ac", "hei a c",

      // "halo" variants
      "halo asi", "halo ace", "halo ase",

      // Bahasa informal
      "eh ac", "eh asi",
    ];

    for (final phrase in phrases) {
      if (text.contains(phrase)) return true;
    }

    // Fuzzy: minimal ada "ac" atau "asi" dan ada kata sapa di dekatnya
    final hasSalutation = RegExp(
      r'\b(hei|hey|hai|halo|he|hi|eh)\b',
    ).hasMatch(text);
    final hasTarget = RegExp(r'\b(ac|asi|ase|ace)\b').hasMatch(text);

    if (hasSalutation && hasTarget) {
      print("WAKEWORD FUZZY MATCH: $text");
      return true;
    }

    return false;
  }

  // =======================================================
  // CLEAN TEXT — buang filler words tanpa merusak kata lain
  // Gunakan word boundary (\b) agar hanya kata utuh yang dihapus
  // =======================================================
  String _cleanText(String text) {
    const fillers = [
      r'\bya\b',
      r'\biya\b',
      r'\boke\b',
      r'\bok\b',
      r'\bem\b',
      r'\beh\b',
      r'\bum\b',
      r'\bah\b',
    ];

    for (final filler in fillers) {
      text = text.replaceAll(RegExp(filler), '');
    }

    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // =======================================================
  // UI BUILD
  // =======================================================
  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (_voiceState) {
      VoiceState.loading => (Colors.red, Icons.hourglass_top),
      VoiceState.idle => (Colors.green, Icons.mic),
      VoiceState.speaking => (Colors.orange, Icons.volume_up),
      VoiceState.command => (Colors.blue, Icons.graphic_eq),
    };

    return FloatingActionButton(
      heroTag: "voice_btn",
      onPressed: _manualPressed,
      backgroundColor: color,
      child: Icon(icon, size: 30),
    );
  }
}
