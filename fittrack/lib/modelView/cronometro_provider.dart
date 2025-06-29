import 'package:flutter/material.dart';
import '../model/modo_cronometro.dart';

class CronoometroSessionViewModel extends ChangeNotifier {
  ModoCronometro? _selectedCronometro;
  int _tiempoObjetivo = 30;

  ModoCronometro? get selectedCronometro => _selectedCronometro;
  int get tiempoObjetivo => _tiempoObjetivo;

  void selectPose(ModoCronometro pose) {
    _selectedCronometro = pose;
    notifyListeners();
  }

  void setTiempoObjetivo(int segundos) {
    _tiempoObjetivo = segundos;
    notifyListeners();
  }

  void clearSession() {
    _selectedCronometro = null;
    _tiempoObjetivo = 30;
    notifyListeners();
  }
}
