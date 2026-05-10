import 'package:flutter/material.dart';
import '../services/mac_storage.dart';

class SettingsPage extends StatefulWidget {
  final String mac;
  final String acBrand;

  const SettingsPage({super.key, required this.mac, required this.acBrand});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String currentMac;

  @override
  void initState() {
    super.initState();
    currentMac = widget.mac;
  }

  /// CHANGE MAC
  void changeMac() {
    TextEditingController controller = TextEditingController(text: currentMac);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Input Your New Device"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "08:F9:E0:BB:CA:60"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () async {
              String newMac = controller.text.trim();

              if (newMac.isEmpty) return;

              Navigator.pop(context); // tutup dialog input

              /// 🔄 SHOW LOADING
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(begin: 0.8, end: 1.0),
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// 🔄 ANIMATED SPINNER
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    189,
                                    248,
                                    248,
                                  ).withOpacity(0.6),
                                  blurRadius: 40,
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              color: Colors.cyanAccent,
                              strokeWidth: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              try {
                /// SIMPAN KE STORAGE
                await MacStorage.saveMac(newMac);

                /// SIMULASI DELAY (biar smooth)
                await Future.delayed(const Duration(milliseconds: 500));

                /// UPDATE UI
                setState(() {
                  currentMac = newMac;
                });

                Navigator.pop(context); // tutup loading

                /// ✅ SUCCESS POPUP
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Berhasil"),
                    content: const Text("MAC Address berhasil diubah"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(
                            context,
                            newMac,
                          ); // 🔥 kirim ke page sebelumnya
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                Navigator.pop(context); // tutup loading

                /// ❌ ERROR POPUP
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Gagal"),
                    content: const Text("Gagal menyimpan MAC Address"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// RESET INFO (UI only)
  void showResetInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Device"),
        content: const Text(
          "Yakin ingin reset? Device ID akan dihapus dan Anda harus setup ulang.",
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Reset"),
            onPressed: () async {
              Navigator.pop(context); // tutup dialog

              /// 🔄 LOADING
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                /// 🔥 HAPUS DEVICE ID
                await MacStorage.clearMac();

                await Future.delayed(const Duration(milliseconds: 400));

                Navigator.pop(context); // tutup loading

                /// ✅ POPUP SUCCESS
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Berhasil"),
                    content: const Text(
                      "Device berhasil di-reset.\nSilakan input Device ID kembali.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);

                          /// 🔥 KIRIM SIGNAL KE PAGE SEBELUMNYA
                          Navigator.pop(context, "RESET");
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                Navigator.pop(context);

                /// ❌ ERROR
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text("Gagal"),
                    content: Text("Reset gagal, coba lagi."),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Device Info",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Brand: ${widget.acBrand}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),

              Text(
                "Device ID: $currentMac",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _card(
            child: ListTile(
              leading: const Icon(Icons.settings_ethernet, color: Colors.white),
              title: const Text(
                "Change Device",
                style: TextStyle(color: Colors.white),
              ),
              onTap: changeMac,
            ),
          ),

          const SizedBox(height: 16),

          _card(
            child: ListTile(
              leading: const Icon(Icons.restart_alt, color: Colors.redAccent),
              title: const Text(
                "Reset Info",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: showResetInfo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
