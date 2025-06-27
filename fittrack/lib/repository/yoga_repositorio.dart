import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/yoga.dart';

class YogaRepository {
  static const _keyYoga = 'yoga';

  Future<void> saveYoga(List<Yoga> newYogaList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Obtener los datos existentes
      final existingData = await fetchYoga();
      
      // 2. Combinar con los nuevos datos
      final combinedList = [...existingData, ...newYogaList];
      
      // 3. Guardar la lista combinada
      final jsonString = json.encode(combinedList.map((e) => e.toJson()).toList());
      await prefs.setString(_keyYoga, jsonString);
      
      debugPrint('Datos guardados correctamente. Total: ${combinedList.length} registros');
    } catch (e) {
      debugPrint('Error al guardar datos: $e');
      rethrow;
    }
  }

  Future<List<Yoga>> fetchYoga() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyYoga);
      
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => Yoga.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
      return [];
    }
  }

  Future<void> clearYoga() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyYoga);
    debugPrint('🧹 Datos de yoga eliminados');
  }
}