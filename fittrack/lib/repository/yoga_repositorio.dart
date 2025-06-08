import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/yoga.dart';

class YogaRepository {
  static const _keyYoga = 'yoga';

  Future<void> saveYoga(List<Yoga> yogaList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(yogaList.map((e) => e.toJson()).toList());
    await prefs.setString(_keyYoga, jsonString);
  }

  Future<List<Yoga>> fetchYoga() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyYoga);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Yoga.fromJson(e)).toList();
  }

  Future<void> clearYoga() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyYoga);
  }
}
