import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/ac_state.dart';
import '../widgets/ac_selector_card.dart';
import '../widgets/target_temperature_control.dart';
import '../widgets/environment_card.dart';
import '../widgets/fan_speed_icon.dart';
import '../widgets/ac_mode.dart';
import '../widgets/swing_control.dart';
import '../widgets/power_fab.dart';
import '../widgets/stt_button.dart';
import '../services/mac_storage.dart';
import '../services/voice_commands.dart';
import 'settings_page.dart';

class ACControlPage extends StatefulWidget {
  const ACControlPage({super.key});

  @override
  State<ACControlPage> createState() => _ACControlPageState();
}

class _ACControlPageState extends State<ACControlPage> {
  final FlutterTts tts = FlutterTts();

  late String mac;
  late VoiceCommandService voiceService;
  late DatabaseReference settingsRef;
  late DatabaseReference sensorRef;
  late ACState state;

  bool deviceConnected = false;

  double? roomTemperature;
  double? humidity;

  /// timestamp FINAL COMMAND dari voice
  int? _lastSpeechFinishedTs;

  @override
  void initState() {
    super.initState();

    state = ACState();

    initTTS();
    voiceService = VoiceCommandService(tts);

    initMac();
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  /// =====================================================
  /// INIT MAC
  /// =====================================================
  Future<void> initMac() async {
    final savedMac = await MacStorage.loadMac();

    if (savedMac == null || savedMac.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, "/setup");
      });
      return;
    }

    mac = savedMac;

    settingsRef = FirebaseDatabase.instance.ref("devices/$mac/settings");
    sensorRef = FirebaseDatabase.instance.ref("devices/$mac/sensors");

    listenToSettings();
    listenToSensors();

    setState(() {});
  }

  /// =====================================================
  /// LISTEN SETTINGS
  /// =====================================================
  void listenToSettings() {
    settingsRef.onValue.listen((event) {
      if (event.snapshot.value == null) {
        setState(() => deviceConnected = false);
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      setState(() {
        state.isPowerOn = data["power"] ?? false;
        state.targetTemperature = (data["temp"] ?? 24).toInt();
        state.fanSpeed = (data["fan_speed"] ?? 1).toInt();
        state.mode = (data["mode"] ?? 1).toInt();
        state.swingOn = data["swing"] ?? false;

        int protocol = (data["protocol_id"] ?? 14).toInt();

        state.selectedAC = state.protocolMap.entries
            .firstWhere(
              (e) => e.value == protocol,
              orElse: () => const MapEntry("Daikin", 14),
            )
            .key;

        deviceConnected = true;
      });
    });
  }

  /// =====================================================
  /// LISTEN SENSOR
  /// =====================================================
  void listenToSensors() {
    sensorRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      setState(() {
        roomTemperature = (data["read_temp"] as num?)?.toDouble();
        humidity = (data["read_hum"] as num?)?.toDouble();
      });
    });
  }

  String formatWIB(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}:"
        "${dt.second.toString().padLeft(2, '0')} WIB";
  }

  Future<void> updateFirebase() async {
    final startTs =
        _lastSpeechFinishedTs ?? DateTime.now().millisecondsSinceEpoch;

    final isVoice = _lastSpeechFinishedTs != null;

    print("=======================================");
    print(isVoice ? "VOICE COMMAND" : "MANUAL COMMAND");
    print("START TS : $startTs");
    print("START TIME WIB : ${formatWIB(startTs)}");

    await settingsRef.update({
      "power": state.isPowerOn,
      "temp": state.targetTemperature,
      "fan_speed": state.fanSpeed,
      "mode": state.mode,
      "swing": state.swingOn,
      "protocol_id": state.protocolId,

      /// timestamp FINAL COMMAND
      "command_timestamp": startTs,
    });

    final ackTs = DateTime.now().millisecondsSinceEpoch;

    final latency = ackTs - startTs;

    print("FIREBASE ACK TS : $ackTs");
    print("ACK TIME WIB   : ${formatWIB(ackTs)}");
    print("TOTAL LATENCY   : $latency ms");
    print("=======================================");

    if (kDebugMode) {
      debugPrint("UPDATED TO FIREBASE");
    }

    /// reset supaya manual command berikutnya tidak pakai timestamp lama
    _lastSpeechFinishedTs = null;
  }

  /// =====================================================
  /// TTS
  /// =====================================================
  Future<void> initTTS() async {
    var voices = await tts.getVoices;

    for (var v in voices) {
      if (v["locale"].toString().contains("id")) {
        await tts.setVoice({"name": v["name"], "locale": v["locale"]});
        break;
      }
    }

    await tts.setSpeechRate(0.5);
  }

  /// =====================================================
  /// UI
  /// =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Column(
              children: [
                /// HEADER
                Row(
                  children: [
                    const Text(
                      "AC Controller",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SettingsPage(
                              mac: mac,
                              acBrand: state.selectedAC,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// AC SELECTOR + STT
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: ACSelectorCard(
                        acList: state.acList,
                        selectedAC: state.selectedAC,
                        onChanged: (v) {
                          setState(() => state.selectedAC = v);
                          updateFirebase();
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      flex: 2,
                      child: SttButton(
                        onResult: (text) async {
                          /// FINAL COMMAND timestamp
                          _lastSpeechFinishedTs =
                              DateTime.now().millisecondsSinceEpoch;

                          await voiceService.process(
                            command: text,
                            state: state,
                            onUpdate: () async {
                              await updateFirebase();
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// TEMP
                TargetTemperatureControl(
                  temperature: state.targetTemperature,
                  onChanged: (v) {
                    setState(() => state.targetTemperature = v);
                    updateFirebase();
                  },
                ),

                const SizedBox(height: 16),

                /// SENSOR
                EnvironmentCard(
                  temperature: roomTemperature,
                  humidity: humidity,
                  enabled: state.isPowerOn,
                ),

                const SizedBox(height: 16),

                /// SWING
                SwingControl(
                  enabled: state.isPowerOn,
                  isOn: state.swingOn,
                  onChanged: (v) {
                    setState(() => state.swingOn = v);
                    updateFirebase();
                  },
                ),

                const SizedBox(height: 16),

                /// FAN + MODE
                Row(
                  children: [
                    Expanded(
                      child: FanSpeedControl(
                        speed: state.fanSpeed,
                        enabled: state.isPowerOn,
                        onChanged: (v) {
                          setState(() => state.fanSpeed = v);
                          updateFirebase();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AcModeControl(
                        mode: state.mode,
                        enabled: state.isPowerOn,
                        onChanged: (v) {
                          setState(() => state.mode = v);
                          updateFirebase();
                        },
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                /// POWER
                PowerFAB(
                  isOn: state.isPowerOn,
                  onToggle: () {
                    setState(() => state.isPowerOn = !state.isPowerOn);
                    updateFirebase();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
