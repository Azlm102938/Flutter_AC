import 'package:flutter_tts/flutter_tts.dart';
import '../models/ac_state.dart';

class VoiceCommandService {
  final FlutterTts tts;

  VoiceCommandService(this.tts);

  Future<void> process({
    required String command,
    required ACState state,
    required Future<void> Function() onUpdate,
  }) async {
    // =====================================================
    // NORMALIZE
    // =====================================================
    command = command.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    command = _autoCorrect(command);

    print("VOICE COMMAND (corrected): $command");

    List<String> responses = [];

    // =====================================================
    // POWER ON
    // =====================================================
    if (_hasAny(command, [
      "nyalakan ac",
      "nyalain ac",
      "hidupkan ac",
      "ac nyala",
      "ac hidup",
      "turn on ac",
      "ac dinyalakan",
      // STT typo variants
      "nla ac",
      "nla kan ac",
      "nyala ac",
    ])) {
      state.isPowerOn = true;
      responses.add("AC dinyalakan");
    }

    // =====================================================
    // POWER OFF
    // =====================================================
    if (_hasAny(command, [
      "matikan ac",
      "matiin ac",
      "ac mati",
      "turn off ac",
      "ac dimatikan",
      // STT typo variants
      "matiin ac",
      "matian ac",
      "mati ac",
    ])) {
      state.isPowerOn = false;
      responses.add("AC dimatikan");
    }

    // =====================================================
    // BRAND
    // =====================================================
    if (_hasAny(command, [
      "daikin",
      "daykin",
      "dekin",
      "deikin",
      "daikain",
      "daiken",
    ])) {
      state.selectedAC = "Daikin";
      responses.add("AC Daikin dipilih");
    }

    if (_hasAny(command, ["lg", "elji", "elg", "elgee", "elgi", "el ji"])) {
      state.selectedAC = "LG";
      responses.add("AC LG dipilih");
    }

    if (_hasAny(command, ["panasonic", "panasonik", "panasoni"])) {
      state.selectedAC = "Panasonic";
      responses.add("AC Panasonic dipilih");
    }

    if (_hasAny(command, ["sharp", "sarp", "syarp", "syar"])) {
      state.selectedAC = "Sharp";
      responses.add("AC Sharp dipilih");
    }

    if (_hasAny(command, ["gree", "gri", "grie", "grei", "gre", "grees"])) {
      state.selectedAC = "Gree";
      responses.add("AC Gree dipilih");
    }

    if (_hasAny(command, [
      "samsung",
      "samssung",
      "samsun",
      "samsong",
      "samsung",
    ])) {
      state.selectedAC = "Samsung";
      responses.add("AC Samsung dipilih");
    }

    // =====================================================
    // TEMPERATURE
    // Hanya trigger jika ada angka eksplisit
    // =====================================================
    final hasTemperatureKeyword = _hasAny(command, [
      "suhu",
      "temperatur",
      "temperature",
      "derajat",
    ]);

    if (hasTemperatureKeyword) {
      final temp = _extractNumber(command);

      if (temp != null) {
        if (temp >= 16 && temp <= 30) {
          state.targetTemperature = temp;
          responses.add("Suhu diatur ke $temp derajat");
        } else {
          responses.add("Suhu harus antara 16 sampai 30 derajat");
        }
      } else {
        responses.add("Sebutkan angka suhu yang diinginkan");
      }
    }

    // =====================================================
    // FAN SPEED
    // =====================================================
    if (_hasAny(command, ["kipas auto", "kipas otomatis", "fan auto"])) {
      state.fanSpeed = 0;
      responses.add("Kipas otomatis");
    } else if (_hasAny(command, [
      "kipas pelan",
      "kipas lambat",
      "kipas kecil",
      "kipas 1",
      "kipasnya kecilin",
      "kecilin kipas",
      "kecilkan kipas",
      "fan pelan",
      "fan kecil",
    ])) {
      state.fanSpeed = 1;
      responses.add("Kipas pelan");
    } else if (_hasAny(command, [
      "kipas sedang",
      "kipas medium",
      "kipas 2",
      "kipas normal",
      "sedangin kipas",
      "fan sedang",
      "fan medium",
    ])) {
      state.fanSpeed = 2;
      responses.add("Kipas sedang");
    } else if (_hasAny(command, [
      "kipas kencang",
      "kipas cepat",
      "kipas besar",
      "kipas tinggi",
      "kipas high",
      "kipas 3",
      "kipas maksimal",
      "kencengin kipas",
      "fan kencang",
      "fan tinggi",
      "fan besar",
    ])) {
      state.fanSpeed = 3;
      responses.add("Kipas kencang");
    }

    // =====================================================
    // MODE
    // =====================================================
    if (_hasAny(command, [
      "mode auto",
      "mode otomatis",
      "model otomatis",
      "auto mode",
      "mod auto",
    ])) {
      state.mode = 0;
      responses.add("Mode otomatis");
    } else if (_hasAny(command, [
      "mode normal",
      "model normal",
      "normal mode",
      "mod normal",
    ])) {
      state.mode = 1;
      responses.add("Mode normal");
    } else if (_hasAny(command, [
      "mode kering",
      "mod kering",
      "model kering",
      "mode dry",
    ])) {
      state.mode = 2;
      responses.add("Mode kering");
    } else if (_hasAny(command, [
      "mode kipas",
      "mode angin",
      "mode fan",
      "mod kipas",
      "model kipas",
    ])) {
      state.mode = 3;
      responses.add("Mode kipas");
    }

    // =====================================================
    // SWING
    // =====================================================
    if (_hasAny(command, [
      "nyalakan ayun",
      "aktifkan ayun",
      "ayun nyala",
      "ayun hidup",
      "hidupkan ayun",
      "ayun on",
      "nyalakan mode ayun"
          // STT typo
          "nla kan ayun",
      "nla ayun",
    ])) {
      state.swingOn = true;

      responses.add("Ayun diaktifkan");
    }

    if (_hasAny(command, [
      "matikan ayun",
      "ayun mati",
      "matiin ayun",
      "nonaktifkan ayun",
      "hentikan ayun",
      "matikan mode ayun",
      "ayun off",
    ])) {
      state.swingOn = false;
      responses.add("Ayun dimatikan");
    }

    // =====================================================
    // DEFAULT
    // =====================================================
    if (responses.isEmpty) {
      responses.add("Maaf, perintah tidak dikenali");
    }

    // =====================================================
    // UPDATE
    // =====================================================
    await onUpdate();

    // =====================================================
    // TTS RESPONSE
    // =====================================================
    final response = responses.join(". ");

    print("VOICE RESPONSE: $response");

    await Future.delayed(const Duration(milliseconds: 300));
    await tts.stop();
    await tts.speak(response);
  }

  // =====================================================
  // AUTO CORRECT
  // Hanya koreksi kata utuh, bukan substring
  // =====================================================
  String _autoCorrect(String text) {
    final fixes = <String, String>{
      // "ac" variants
      r'\basi\b': 'ac',
      r'\basih\b': 'ac',
      r'\besi\b': 'ac',
      r'\bace\b': 'ac',

      // "nyala" STT typo variants
      r'\bnla\b': 'nyala',
      r'\bnyla\b': 'nyala',
      r'\bnyalah\b': 'nyala',
      r'\bnyla kan\b': 'nyalakan',
      r'\bnla kan\b': 'nyalakan',

      // "mode" typo
      r'\bkode\b': 'mode',
      r'\bmod\b': 'mode',
      r'\bmote\b': 'mode',

      // "matikan" typo
      r'\bmatian\b': 'matikan',
      r'\bmatikin\b': 'matikan',

      // "kipas" typo
      r'\bkipas\b': 'kipas', // sudah benar, tapi jaga-jaga
      r'\bkipa\b': 'kipas',

      // "derajat" typo
      r'\bderajad\b': 'derajat',

      // "suhu" typo
      r'\bsuhu\b': 'suhu',
      r'\bsubu\b': 'suhu',
    };

    fixes.forEach((pattern, replacement) {
      text = text.replaceAll(RegExp(pattern), replacement);
    });

    return text.trim();
  }

  // =====================================================
  // HELPERS
  // =====================================================
  bool _hasAny(String text, List<String> keys) {
    for (final key in keys) {
      if (text.contains(key)) return true;
    }
    return false;
  }

  int? _extractNumber(String text) {
    final match = RegExp(r'\d+').firstMatch(text);
    if (match != null) return int.tryParse(match.group(0)!);
    return null;
  }
}
