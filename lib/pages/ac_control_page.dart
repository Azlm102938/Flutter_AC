import 'package:flutter/material.dart';
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
  late DatabaseReference dbRef;
  late ACState state;

  bool deviceConnected = false;

  int roomTemperature = 25;
  int humidity = 50;

  @override
  void initState() {
    super.initState();

    state = ACState();

    initTTS(); // 🔥 penting

    voiceService = VoiceCommandService(tts);

    initMac();
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  Future<void> initMac() async {
    final savedMac = await MacStorage.loadMac();

    if (savedMac == null || savedMac.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, "/setup");
      });
      return;
    }

    mac = savedMac;

    dbRef = FirebaseDatabase.instance.ref("devices/$mac/settings");

    listenToFirebase();
    setState(() {});
  }

  void listenToFirebase() {
    dbRef.onValue.listen((event) {
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
        roomTemperature = (data["read_temp"] as num?)?.toInt() ?? 25;
        humidity = (data["read_hum"] as num?)?.toInt() ?? 50;

        /// 🔥 protocol_id → convert to brand name
        int protocol = (data["protocol_id"] ?? 14).toInt();

        state.selectedAC = state.protocolMap.entries
            .firstWhere(
              (e) => e.value == protocol,
              orElse: () => const MapEntry("Daikin", 14),
            )
            .key;

        deviceConnected = true;
      });

      print("SYNCED FROM FIREBASE");
    });
  }

  void updateFirebase() async {
    await dbRef.update({
      "power": state.isPowerOn,
      "temp": state.targetTemperature,
      "fan_speed": state.fanSpeed,
      "mode": state.mode,
      "swing": state.swingOn,
      "protocol_id": state.protocolId,
    });

    print("UPDATED TO FIREBASE");
  }

  Future<void> initTTS() async {
    var voices = await tts.getVoices;

    print("VOICES: $voices");

    for (var v in voices) {
      if (v["locale"].toString().contains("id")) {
        await tts.setVoice({"name": v["name"], "locale": v["locale"]});
        break;
      }
    }

    await tts.setSpeechRate(0.5);
  }

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
                Padding(
                  padding: const EdgeInsets.only(left: 4),

                  child: Row(
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

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SettingsPage(
                                  mac: mac,
                                  acBrand: state.selectedAC,
                                ),
                              ),
                            );

                            if (result == "RESET") {
                              Navigator.pushReplacementNamed(context, "/setup");
                            } else if (result != null) {
                              setState(() {
                                mac = result;

                                dbRef = FirebaseDatabase.instance.ref(
                                  "devices/$mac/settings",
                                );

                                listenToFirebase();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                /// AC SELECTOR & VOICE
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
                          await voiceService.process(
                            command: text,
                            state: state,
                            onUpdate: () {
                              updateFirebase();
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 160,
                  child: Opacity(
                    opacity: state.isPowerOn ? 1 : 0.4,
                    child: TargetTemperatureControl(
                      temperature: state.targetTemperature,
                      onChanged: (v) {
                        setState(() => state.targetTemperature = v);
                        updateFirebase();
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// ENVIRONMENT
                SizedBox(
                  height: 100,
                  child: EnvironmentCard(
                    temperature: roomTemperature,
                    humidity: humidity,
                    enabled: state.isPowerOn,
                  ),
                ),

                const SizedBox(height: 16),

                /// SWING
                SizedBox(
                  width: double.infinity,
                  child: SwingControl(
                    enabled: state.isPowerOn,
                    isOn: state.swingOn,
                    onChanged: (v) {
                      setState(() => state.swingOn = v);
                      updateFirebase();
                    },
                  ),
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
                    const SizedBox(width: 14),
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

                /// POWER BUTTON
                Center(
                  child: PowerFAB(
                    isOn: state.isPowerOn,
                    onToggle: () {
                      setState(() => state.isPowerOn = !state.isPowerOn);
                      updateFirebase();
                    },
                  ),
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
