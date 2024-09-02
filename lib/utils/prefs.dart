import 'package:shared_preferences/shared_preferences.dart';

Future<void> setPrefs(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String?> getPrefs(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final data = prefs.getString(key);
  return data;
}

Future<void> removePrefs(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('login');
}