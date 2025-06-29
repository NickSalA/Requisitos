// lib/modelView/cronometro_provider.dart
import 'package:flutter/material.dart';
import '../model/modo_cronometro.dart';
import '../repository/cronometro_repository.dart';

class CronoometroSessionViewModel extends ChangeNotifier {
  ModoCronometro? _selectedCronometro;
  int _tiempoObjetivo = 30; // segundos por postura
  final List<int> _duracionesReales = [];

  ModoCronometro? get selectedCronometro => _selectedCronometro;
  int get tiempoObjetivo => _tiempoObjetivo;
  List<int> get duracionesReales => List.unmodifiable(_duracionesReales);

  void selectPose(ModoCronometro pose) {
    _selectedCronometro = pose;
    _duracionesReales.clear();
    notifyListeners();
  }

  void setTiempoObjetivo(int segundos) {
    _tiempoObjetivo = segundos;
    notifyListeners();
  }

  /// Llama esto desde la pantalla de sesión cada vez que completes una postura.
  void addDuracionReal(int seg) {
    _duracionesReales.add(seg);
  }

  /// Persiste en SharedPreferences y limpia el estado.
  Future<void> finishAndSave() async {
    if (_selectedCronometro == null) return;

    final total = _duracionesReales.fold<int>(0, (a, b) => a + b);
    final repo = CronometroRepository();
    final prev = await repo.fetchCronometro();

    await repo.saveEjercicios([
      ...prev,
      _selectedCronometro!.copyWith(
        duracion: total,
        fechaCreacion: DateTime.now(),
      ),
    ]);

    clearSession();
  }

  void clearSession() {
    _selectedCronometro = null;
    _tiempoObjetivo = 30;
    _duracionesReales.clear();
    notifyListeners();
  }
}
