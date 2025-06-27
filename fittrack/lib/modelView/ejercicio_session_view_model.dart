import 'dart:async';
import 'package:flutter/material.dart';

class EjercicioSessionViewModel extends ChangeNotifier {
  int _serieActual = 1;
  int _repeticionActual = 0;
  String _mensajeFeedback = "¡Vamos a empezar!";
  final int repeticionesPorSerie;
  final int totalSeries;
  final int descansoSegundos;

  bool _enDescanso = false;
  int _tiempoRestante = 0;
  Timer? _timer;

  // Estado para detectar transición sentadilla abajo → arriba
  bool estabaAbajo = false;

  // Nuevos datos para resumen de sesión
  int _repeticionesIncorrectas = 0;
  List<List<double>> _keypointsActuales = [];

  EjercicioSessionViewModel({
    this.repeticionesPorSerie = 10,
    this.totalSeries = 3,
    this.descansoSegundos = 30,
  });

  int get serieActual => _serieActual;
  int get repeticionActual => _repeticionActual;
  String get mensajeFeedback => _mensajeFeedback;
  bool get enDescanso => _enDescanso;
  int get tiempoRestante => _tiempoRestante;

  int get repeticionesCorrectas => (_serieActual - 1) * repeticionesPorSerie + _repeticionActual;
  int get repeticionesIncorrectas => _repeticionesIncorrectas;

  double get porcentajeEfectividad {
    final total = repeticionesCorrectas + _repeticionesIncorrectas;
    if (total == 0) return 0;
    return (repeticionesCorrectas / total) * 100;
  }

  List<List<double>> get keypointsActuales => _keypointsActuales;

  void actualizarKeypoints(List<List<double>> nuevos) {
    _keypointsActuales = nuevos;
    notifyListeners();
  }

  void registrarRepeticionIncorrecta() {
    _repeticionesIncorrectas++;
    actualizarFeedback("Corrige tu postura");
    notifyListeners();
  }

  void incrementarRepeticion({bool posturaCorrecta = true}) {
    if (_enDescanso || _serieActual > totalSeries) return;

    if (!posturaCorrecta) {
      registrarRepeticionIncorrecta();
      return;
    }

    _repeticionActual++;

    if (_repeticionActual >= repeticionesPorSerie) {
      _repeticionActual = 0;

      if (_serieActual < totalSeries) {
        _iniciarDescanso();
        _serieActual++;
      } else {
        actualizarFeedback("¡Ejercicio completado!");
      }
    } else {
      actualizarFeedback(_generarMensaje());
    }

    notifyListeners();
  }

  void _iniciarDescanso() {
    _enDescanso = true;
    _tiempoRestante = descansoSegundos;
    actualizarFeedback("Descanso: $_tiempoRestante s");

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tiempoRestante--;
      if (_tiempoRestante <= 0) {
        _timer?.cancel();
        _enDescanso = false;
        actualizarFeedback("¡Vamos con la siguiente serie!");
      } else {
        actualizarFeedback("Descanso: $_tiempoRestante s");
      }
      notifyListeners();
    });

    notifyListeners();
  }

  void actualizarFeedback(String nuevoMensaje) {
    _mensajeFeedback = nuevoMensaje;
    notifyListeners();
  }

  String _generarMensaje() {
    if (_repeticionActual == 0) return "¡Vamos!";
    if (_repeticionActual < repeticionesPorSerie / 2) return "¡Vas bien!";
    if (_repeticionActual < repeticionesPorSerie) return "¡Casi terminas!";
    return "¡Excelente!";
  }

  void reiniciar() {
    _serieActual = 1;
    _repeticionActual = 0;
    _mensajeFeedback = "¡Vamos a empezar!";
    _enDescanso = false;
    _tiempoRestante = 0;
    estabaAbajo = false;
    _repeticionesIncorrectas = 0;
    _keypointsActuales = [];
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
