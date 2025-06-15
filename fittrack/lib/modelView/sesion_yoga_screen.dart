import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../model/pose_pipeline_helper.dart'; // Cambia el import a donde tengas tu pipeline

class PoseSessionViewModel extends ChangeNotifier {
  late CameraController _cameraController;
  late PosePipelineHelper _pipeline;

  int _countdown = 0;
  int _stablePoseSeconds = 0;
  bool _poseCorrect = false;
  bool _sessionStarted = false;
  bool _sessionFinished = false;
  String? _feedback;
  List<List<double>>? _keypoints;
  Timer? _mainTimer;
  Timer? _poseValidationTimer;

  CameraController get cameraController => _cameraController;
  bool get isPoseCorrect => _poseCorrect;
  int get countdown => _countdown;
  bool get sessionStarted => _sessionStarted;
  bool get sessionFinished => _sessionFinished;
  String? get feedback => _feedback;
  List<List<double>>? get keypoints => _keypoints;
  bool _isProcessing = false;

  void finishSession() {
    _poseValidationTimer?.cancel();
    _mainTimer?.cancel();
    _cameraController.dispose();
    _pipeline.dispose();
    _sessionFinished = true;
    notifyListeners();
  }

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
  }

  Future<void> initialize(
    CameraDescription camera,
    int tiempoObjetivo,
    String expectedPose,
  ) async {
    _cameraController =
        CameraController(camera, ResolutionPreset.low, enableAudio: false);
    await _cameraController.initialize();

    _pipeline = PosePipelineHelper();
    await _pipeline.init();

    _isProcessing = false;
    await _cameraController.startImageStream((image) {
      if (_isProcessing) return;
      _isProcessing = true;

      Future(() async {
        debugPrint('🔥 Recibido frame de cámara');
        try {
          final result = await _pipeline.classifyFromCamera(image);
          debugPrint(
              '🔎 Resultado del pipeline: ${result.clase}, conf=${result.confianza}');
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
