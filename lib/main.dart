import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pages/ac_control_page.dart';
import 'pages/setup_device_page.dart';
import 'services/mac_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCCehP5XxVuF4jOqi5jBLJgMfXOEVqYbEE",
      appId: "1:968840001299:android:446cd364185b9955398ce6",
      messagingSenderId: "968840001299",
      projectId: "smartremote-1e9be",
      databaseURL:
          "https://smartremote-1e9be-default-rtdb.asia-southeast1.firebasedatabase.app",
      storageBucket: "smartremote-1e9be.firebasestorage.app",
    ),
  );

  runApp(const ACApp());
}

class ACApp extends StatelessWidget {
  const ACApp({super.key});

  Future<bool> _hasMac() async {
    final mac = await MacStorage.loadMac();
    return mac != null && mac.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// 🔥 ROUTES
      routes: {
        "/home": (_) => const ACControlPage(),
        "/setup": (_) => const SetupDevicePage(),
      },

      /// 🔥 CEK AWAL
      home: FutureBuilder<bool>(
        future: _hasMac(),
        builder: (context, snapshot) {
          /// loading
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          /// kalau sudah ada MAC
          if (snapshot.data!) {
            return const ACControlPage();
          }

          /// kalau belum ada MAC
          return const SetupDevicePage();
        },
      ),
    );
  }
}
