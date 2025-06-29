import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../model/pipeline.dart'; // Cambia el import a donde tengas tu pipeline
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fittrack/model/yoga.dart';
import 'package:fittrack/repository/yoga_repositorio.dart';

class PoseSessionViewModel extends ChangeNotifier {
  late CameraController _cameraController;
  late PosePipelineHelper _pipeline;

  int _countdown = 0;
  int _stablePoseSeconds = 0;
  bool _poseCorrect = false;
  bool _sessionStarted = false;
  bool _sessionFinished = false;
  Yoga? _resumen;
  late String _poseName;
  late String _imagenPath;
  String? _feedback;
  List<List<double>>? _keypoints;
  Timer? _mainTimer;
  Timer? _poseValidationTimer;
  Timer? _tiempoTimer;
  int _tiempoCorrecto = 0;
  int _tiempoIncorrecto = 0;
  Yoga? get resumen => _resumen;
  int get tiempoCorrecto => _tiempoCorrecto;
  int get tiempoIncorrecto => _tiempoIncorrecto;
  CameraController get cameraController => _cameraController;
  bool get isPoseCorrect => _poseCorrect;
  int get countdown => _countdown;
  bool get sessionStarted => _sessionStarted;
  bool get sessionFinished => _sessionFinished;
  String? get feedback => _feedback;
  List<List<double>>? get keypoints => _keypoints;
  bool _isProcessing = false;

  void _startMainTimer(int duration) {
    _sessionStarted = true;
    _countdown = duration;
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_poseCorrect) return;
      _countdown--;
      notifyListeners();
      if (_countdown <= 0) {
        finishSession();
      }
    });
    _tiempoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_poseCorrect) {
        _tiempoCorrecto++;
      } else {
        _tiempoIncorrecto++;
      }
    });
  }

  Future<void> initialize(
    CameraDescription camera,
    int tiempoObjetivo,
    String expectedPose,
    String imagePath,
  ) async {
    _poseName = expectedPose;
    _imagenPath = imagePath;
    _cameraController = CameraController(camera, ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420);
    await _cameraController.initialize();

    _pipeline = PosePipelineHelper();
    await _pipeline.init();

    _isProcessing = false;
    await _cameraController.startImageStream((image) {
      if (_isProcessing) return;
      _isProcessing = true;

      Future(() async {
        try {
          final result =
              await _pipeline.classifyFromCamera(image, expectedPose);
          // debugPrint(
          // '🔎 Resultado del pipeline: ${result.clase}, conf=${result.confianza}');
          _keypoints = result.keypoints;
          _feedback = result.feedback;

          final bool correct =
              result.clase.toLowerCase().contains(expectedPose.toLowerCase());
          if (!_sessionStarted) {
            if (correct) {
              _stablePoseSeconds++;
              if (_stablePoseSeconds >= 2) {
                _startMainTimer(tiempoObjetivo);
              }
            } else {
              _stablePoseSeconds = 0;
            }
          }
          _poseCorrect = correct;
          notifyListeners();
        } catch (e) {
          debugPrint('Error al procesar frame: $e');
        }
        _isProcessing = false;
      });
    });
  }

  Future<void> finishSession() async {
    _poseValidationTimer?.cancel();
    _mainTimer?.cancel();
    _sessionFinished = true;

    _resumen = Yoga(
      id: DateTime.now().millisecondsSinceEpoch,
      nombre: _poseName,
      descripcion: 'Sesión de postura de $_poseName',
      imagenPath: _imagenPath,
      tipo: 'yoga',
      duracion: _tiempoCorrecto + _tiempoIncorrecto,
      duractionCorrecta: _tiempoCorrecto,
      duracionIncorrecta: _tiempoIncorrecto,
      fechaCreacion: DateTime.now(),
    );

    await _guardarEnHistorial(_resumen!);
    notifyListeners();
  }

  Future<void> _guardarEnHistorial(Yoga yoga) async {
    final repo = YogaRepository();
  await repo.saveYoga([yoga]);
  }

  @override
  void dispose() {
    _poseValidationTimer?.cancel();
    _mainTimer?.cancel();
    if (_cameraController.value.isStreamingImages) {
      _cameraController.stopImageStream();
    }
    _cameraController.dispose();
    _pipeline.dispose();
    super.dispose();
  }
}
