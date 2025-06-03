import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/usuario.dart';

class UsuarioRepository {
  static const _keyUsuario = 'usuario';
  static const _keySeenOnboarding = 'seenOnboarding';

  Future<void> saveUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(usuario.toJson());
    await prefs.setString(_keyUsuario, jsonString);
    await prefs.setBool(_keySeenOnboarding, true);
  }

  Future<Usuario?> fetchUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUsuario);
    if (jsonString == null) return null;
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return Usuario.fromJson(map);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeenOnboarding) ?? false;
  }
}
