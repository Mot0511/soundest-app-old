import 'package:shared_preferences/shared_preferences.dart';

// Занесение данных в хранилище параметров (SharedPreferences)
Future<void> setPrefs(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

// Получение данных из хранилище параметров (SharedPreferences)
Future<String?> getPrefs(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final data = prefs.getString(key);
  return data;
}

// Удаление данных из хранилище параметров (SharedPreferences)
Future<void> removePrefs(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('login');
}