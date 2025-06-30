import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/modo_cronometro.dart';

class CronometroRepository {
  static const _keyEjercicios = 'cronometro';

  Future<void> saveCronometro(List<ModoCronometro> cronometro) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(cronometro.map((e) => e.toJson()).toList());
    await prefs.setString(_keyEjercicios, jsonString);
  }

  Future<List<ModoCronometro>> fetchCronometro() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyEjercicios);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => ModoCronometro.fromJson(e)).toList();
  }

  Future<void> clearCronometro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEjercicios);
  }
}
