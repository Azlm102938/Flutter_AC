import 'package:shared_preferences/shared_preferences.dart';

class MacStorage {
  static const String key = "saved_mac";

  static Future<void> saveMac(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, mac);
  }

  static Future<String?> loadMac() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> clearMac() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
