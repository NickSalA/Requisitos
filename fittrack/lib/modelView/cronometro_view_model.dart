import 'dart:async';
import 'package:flutter/material.dart';
import '../model/modo_cronometro.dart';
import '../repository/modo_cronometro_repositorio.dart';

/// View-model que controla una sesión de cronómetro:
/// – cuenta atrás de preparación
/// – temporizador por postura (pausa / avanzar / retroceder)
/// – cálculo de duraciones reales
/// – guardado en SharedPreferences al terminar
class PoseCronometroSessionViewModel extends ChangeNotifier {
  PoseCronometroSessionViewModel({
    required this.sesion,
    required this.tiempoObjetivo,
  }) {
    _secondsLeft = _prepSeconds;
    _startTimer();
  }

  /* ---------- configuración recibida ---------- */
  final ModoCronometro sesion; // sesión original (imágenes, texto…)
  final int tiempoObjetivo; // segundos por postura
  final int _prepSeconds = 10; // cuenta atrás inicial

  /* ---------- estado interno ---------- */
  int _index = 0; // pose actual
  int _secondsLeft = 0; // segundos restantes
  bool _isPrep = true; // en preparación
  bool _isPaused = false; // en pausa
  final List<int> _duracionesReales = []; // segundos por pose
  Timer? _timer;

  /* ---------- getters para la UI ---------- */
  int get index => _index;
  int get secondsLeft => _secondsLeft;
  bool get isPrep => _isPrep;
  bool get isPaused => _isPaused;
  List<int> get duracionesReales => List.unmodifiable(_duracionesReales);

  /* ---------- controles ---------- */
  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void next() {
    if (_index < sesion.posesPath.length - 1) {
      _duracionesReales.add(tiempoObjetivo);
      _index++;
      _secondsLeft = tiempoObjetivo;
      _isPaused = false;
      notifyListeners();
    } else {
      finish();
    }
  }

  void previous() {
    if (_index == 0) return;
    _index--;
    if (_duracionesReales.isNotEmpty) _duracionesReales.removeLast();
    _secondsLeft = tiempoObjetivo;
    notifyListeners();
  }

  /* ---------- temporizador ---------- */
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;

      if (_secondsLeft > 0) {
        _secondsLeft--;
        notifyListeners();
      } else {
        if (_isPrep) {
          _isPrep = false; // termina la preparación
          _secondsLeft = tiempoObjetivo; // arranca primera pose
          notifyListeners();
        } else {
          next(); // pasa a la siguiente o finaliza
        }
      }
    });
  }

  /* ---------- finalización ---------- */
  VoidCallback? _onFinish;
  void registerOnFinish(VoidCallback cb) => _onFinish = cb;

  Future<void> finish() async {
    _timer?.cancel();
    if (!_isPrep) _duracionesReales.add(tiempoObjetivo); // última pose

    await _guardarEnHistorial(); // persiste la sesión
    _onFinish?.call(); // notifica a la pantalla para navegar
  }

  /* ---------- persistencia ---------- */
  Future<void> _guardarEnHistorial() async {
    final total = _duracionesReales.fold<int>(0, (a, b) => a + b);

    // Creamos un nuevo objeto con la duración real total
    final nuevo = ModoCronometro(
      id: DateTime.now().millisecondsSinceEpoch,
      nombre: sesion.nombre,
      descripcion: sesion.descripcion,
      tipo: sesion.tipo,
      fechaCreacion: DateTime.now(),
      imagenPath: sesion.imagenPath,
      duracion: total,
      posesPath: sesion.posesPath,
    );

    final repo = CronometroRepository();
    final prev = await repo.fetchCronometro();
    await repo.saveCronometro([...prev, nuevo]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
