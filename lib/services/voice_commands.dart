import 'package:flutter_tts/flutter_tts.dart';
import '../models/ac_state.dart';

class VoiceCommandService {
  final FlutterTts tts;

  VoiceCommandService(this.tts);

  Future<void> process({
    required String command,
    required ACState state,
    required Function() onUpdate,
  }) async {
    command = command.toLowerCase();

    String response = "Perintah tidak dikenali";

    /// POWER
    /// =====================
    if (command.contains("nyalakan ac") ||
        command.contains("nyalain ac") ||
        command.contains("ac nyala") ||
        command.contains("hidupkan ac") ||
        command.contains("turn on") ||
        command.contains("power on")) {
      state.isPowerOn = true;
      response = "AC dinyalakan";
    }

    if (command.contains("matikan ac") ||
        command.contains("matiin ac") ||
        command.contains("ac mati") ||
        command.contains("turn off") ||
        command.contains("power off")) {
      state.isPowerOn = false;
      response = "AC dimatikan";
    }

    /// TEMPERATURE
    /// =====================
    if (command.contains("suhu") || command.contains("temperature")) {
      RegExp exp = RegExp(r'\d+');
      var match = exp.firstMatch(command);

      if (match != null) {
        int temp = int.parse(match.group(0)!);

        if (temp >= 16 && temp <= 30) {
          state.targetTemperature = temp;
          response = "Suhu diatur ke $temp derajat";
        } else {
          response = "Suhu harus antara 16 sampai 30 derajat";
        }
      }
    }

    /// =====================
    /// FAN SPEED
    /// =====================
    if (command.contains("fan auto") || command.contains("fan otomatis")) {
      state.fanSpeed = 0;
      response = "Kipas otomatis";
    }

    if (command.contains("fan low") ||
        command.contains("fan pelan") ||
        command.contains("fan lambat") ||
        command.contains("fan kecil") ||
        command.contains("fen low") ||
        command.contains("fen pelan") ||
        command.contains("fen lambat") ||
        command.contains("fen kecil") ||
        command.contains("fan 1") ||
        command.contains("fen 1") ||
        command.contains("kipas pelan") ||
        command.contains("kipas lambat")) {
      state.fanSpeed = 1;
      response = "Kipas pelan";
    }

    if (command.contains("fan medium") ||
        command.contains("fan sedang") ||
        command.contains("fen medium") ||
        command.contains("fen sedang") ||
        command.contains("fan 2") ||
        command.contains("fen 2") ||
        command.contains("kipas sedang") ||
        command.contains("kipas medium")) {
      state.fanSpeed = 2;
      response = "Kipas sedang";
    }

    if (command.contains("fan high") ||
        command.contains("fan kencang") ||
        command.contains("fan cepat") ||
        command.contains("fan besar") ||
        command.contains("fan tinggi") ||
        command.contains("fen high") ||
        command.contains("fen kencang") ||
        command.contains("fen cepat") ||
        command.contains("fen besar") ||
        command.contains("fen tinggi") ||
        command.contains("fan 3") ||
        command.contains("fen 3") ||
        command.contains("kipas kencang") ||
        command.contains("kipas cepat") ||
        command.contains("kipas besar") ||
        command.contains("kipas tinggi") ||
        command.contains("kipas high") ||
        command.contains("kipas maksimal")) {
      state.fanSpeed = 3;
      response = "Kipas kencang";
    }

    /// MODE
    /// =====================
    if (command.contains("mode auto") ||
        command.contains("mode otomatis") ||
        command.contains("auto mode")) {
      state.mode = 0;
      response = "Mode otomatis";
    }

    if (command.contains("mode normal") ||
        command.contains("mode biasa") ||
        command.contains("normal mode") ||
        command.contains("biasa mode")) {
      state.mode = 1; // NORMAL / COOL
      response = "Mode normal";
    }

    if (command.contains("mode dry") ||
        command.contains("mode drai") ||
        command.contains("dry mode") ||
        command.contains("drai mode") ||
        command.contains("drai") ||
        command.contains("dry") ||
        command.contains("mode kering")) {
      state.mode = 2;
      response = "Mode dry";
    }

    if (command.contains("mode fan") ||
        command.contains("mode kipas") ||
        command.contains("fan mode") ||
        command.contains("kipas mode") ||
        command.contains("mode angin")) {
      state.mode = 3;
      response = "Mode kipas";
    }

    /// BRAND
    /// =====================
    if (command.contains("daikin") ||
        command.contains("daikin") ||
        command.contains("daykin") ||
        command.contains("dekin") ||
        command.contains("deikin") ||
        command.contains("daykin") ||
        command.contains("daikain")) {
      state.selectedAC = "Daikin";
      response = "AC Daikin dipilih";
    }

    if (command.contains("lg") ||
        command.contains("elji") ||
        command.contains("elg") ||
        command.contains("elji") ||
        command.contains("elgee") ||
        command.contains("elgi")) {
      state.selectedAC = "LG";
      response = "AC LG dipilih";
    }

    if (command.contains("panasonic") || command.contains("panasonik")) {
      state.selectedAC = "Panasonic";
      response = "AC Panasonic dipilih";
    }

    if (command.contains("gree") ||
        command.contains("gri") ||
        command.contains("grii") ||
        command.contains("grie") ||
        command.contains("grei") ||
        command.contains("gre")) {
      state.selectedAC = "Gree";
      response = "AC Gree dipilih";
    }

    if (command.contains("samsung") ||
        command.contains("samssung") ||
        command.contains("samsun") ||
        command.contains("samsong") ||
        command.contains("semsang")) {
      state.selectedAC = "Samsung";
      response = "AC Samsung dipilih";
    }

    /// =====================
    /// SWING / WING
    /// =====================
    if (command.contains("swing on") ||
        command.contains("ayun nyala") ||
        command.contains("swing nyala") ||
        command.contains("ayun aktif") ||
        command.contains("aktifkan swing") ||
        command.contains("nyalakan swing") ||
        command.contains("hidupkan swing")) {
      state.swingOn = true;
      response = "Swing diaktifkan";
    }

    if (command.contains("swing off") ||
        command.contains("ayun mati") ||
        command.contains("matikan swing")) {
      state.swingOn = false;
      response = "Swing dimatikan";
    }

    /// 🔄 Update UI + Firebase
    onUpdate();

    /// 🔊 Speak
    await Future.delayed(const Duration(milliseconds: 500));
    await tts.stop();
    await tts.speak(response);
  }
}
