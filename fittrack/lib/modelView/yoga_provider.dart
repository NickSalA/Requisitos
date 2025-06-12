import 'package:flutter/material.dart';
import '../model/yoga.dart';

class YogaSessionViewModel extends ChangeNotifier {
  Yoga? _selectedPose;
  int _tiempoObjetivo = 30;

  Yoga? get selectedPose => _selectedPose;
  int get tiempoObjetivo => _tiempoObjetivo;

  void selectPose(Yoga pose) {
    _selectedPose = pose;
    notifyListeners();
  }

  void setTiempoObjetivo(int segundos) {
    _tiempoObjetivo = segundos;
    notifyListeners();
  }

  void clearSession() {
    _selectedPose = null;
    _tiempoObjetivo = 30;
    notifyListeners();
  }
}
