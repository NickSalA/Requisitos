import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ejercicio.dart';

class EjercicioRepository {
  static const _keyEjercicios = 'ejercicios';

  Future<void> saveEjercicios(List<Ejercicio> ejercicios) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(ejercicios.map((e) => e.toJson()).toList());
    await prefs.setString(_keyEjercicios, jsonString);
  }

  Future<List<Ejercicio>> fetchEjercicios() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyEjercicios);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Ejercicio.fromJson(e)).toList();
  }

  Future<void> clearEjercicios() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEjercicios);
  }
}
