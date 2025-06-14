import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'pose_classifier_helper.dart';

class PoseSessionViewModel extends ChangeNotifier {
  late CameraController _cameraController;
  late PoseClassifierHelper _classifierHelper;

  int _countdown = 0;
  int _stablePoseSeconds = 0;
  bool _poseCorrect = false;
  bool _sessionStarted = false;
  bool _sessionFinished = false;
  String? _currentPose;
  double? _confidence;
  String? _feedback;
  List<dynamic>? _keypoints;

  late Timer _mainTimer;
  late Timer _poseValidationTimer;

  CameraController get cameraController => _cameraController;
  bool get isPoseCorrect => _poseCorrect;
  int get countdown => _countdown;
  List<dynamic>? get keypoints => _keypoints;
  bool get sessionStarted => _sessionStarted;
  bool get sessionFinished => _sessionFinished;
  String? get currentPose => _currentPose;
  double? get confidence => _confidence;
  String? get feedback => _feedback;

  Future<void> initialize(
      CameraDescription camera, int tiempoObjetivo, String expectedPose) async {
    _cameraController = CameraController(camera, ResolutionPreset.low);
    await _cameraController.initialize();

    _classifierHelper = PoseClassifierHelper();
    await _classifierHelper.init();

    bool processing = false;

    await _cameraController.startImageStream((image) async {
      if (processing) return; // Evita concurrencia
      processing = true;
      try {
        final result = await _classifierHelper.inferFromCamera(image);

        _currentPose = result['posture'] as String?;
        _confidence = result['confidence'] as double?;
        _feedback = result['feedbackParteMal'] as String?;
        _keypoints = result['keypoints'] as List<dynamic>?;

        print('Frame recibido:');
        print(
            ' - Pose detectada: $_currentPose (${_confidence?.toStringAsFixed(2)})');
        print('Keypoints: ${_keypoints?.length}');
        print('Feedback: $_feedback');

        final bool correct = _currentPose != null &&
            _currentPose!.toLowerCase().contains(expectedPose.toLowerCase());

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
        debugPrint('Error al procesar la imagen: $e');
      } finally {
        processing = false;
      }
    });
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

  void finishSession() {
    _poseValidationTimer.cancel();
    if (_sessionStarted) _mainTimer.cancel();
    _cameraController.dispose();
    _classifierHelper.close();
    _sessionFinished = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _poseValidationTimer.cancel();
    if (_sessionStarted) _mainTimer.cancel();
    _cameraController.dispose();
    _classifierHelper.close();
    super.dispose();
  }
}

class KeypointsPainter extends CustomPainter {
  final List<dynamic> keypoints;
  final Size? previewSize;

  KeypointsPainter(this.keypoints, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (previewSize == null) return;

    final double scaleX = size.width / previewSize!.height;
    final double scaleY = size.height / previewSize!.width;

    final Paint dotPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 6.0
      ..style = PaintingStyle.fill;

    for (final k in keypoints) {
      final dx = k[0] * scaleX;
      final dy = k[1] * scaleY;
      canvas.drawCircle(Offset(dx, dy), 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
