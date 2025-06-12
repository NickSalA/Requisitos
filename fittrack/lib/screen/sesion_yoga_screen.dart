import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modelView/yoga_provider.dart';
import '../../modelView/pose_classifier_helper.dart';

class SesionYogaScreen extends StatefulWidget {
  const SesionYogaScreen({super.key});

  @override
  State<SesionYogaScreen> createState() => _SesionYogaScreenState();
}

class _SesionYogaScreenState extends State<SesionYogaScreen> {
  late CameraController _cameraController;
  late PoseClassifierHelper _classifierHelper;
  late Timer _mainTimer;
  late Timer _poseDetectionTimer;

  int _currentCountdown = 0;
  int _stablePoseSeconds = 0;
  bool _poseIsCorrect = false;
  bool _sessionStarted = false;
  bool _sessionFinished = false;

  @override
  void initState() {
    super.initState();
    _initializeCameraAndModel();
  }

  Future<void> _initializeCameraAndModel() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.low);
    await _cameraController.initialize();

    _classifierHelper = PoseClassifierHelper();
    await _classifierHelper.init();

    _startPoseValidation();
  }

  void _startPoseValidation() {
    _poseDetectionTimer =
        Timer.periodic(const Duration(milliseconds: 800), (_) async {
      if (!_cameraController.value.isStreamingImages) {
        await _cameraController.startImageStream(_processCameraImage);
      }
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final expectedPose = context.read<YogaSessionViewModel>().selectedPose;
    final tiempoObjetivo = context.read<YogaSessionViewModel>().tiempoObjetivo;

    final result = await _classifierHelper.inferFromCamera(image);
    final String poseDetectada = result['posture'];
    final bool esCorrecta = poseDetectada
        .toLowerCase()
        .contains(expectedPose?.nombre.toLowerCase() ?? '');

    if (!_sessionStarted) {
      if (esCorrecta) {
        _stablePoseSeconds++;
        if (_stablePoseSeconds >= 2) {
          _startMainTimer(tiempoObjetivo);
        }
      } else {
        _stablePoseSeconds = 0;
      }
      setState(() => _poseIsCorrect = esCorrecta);
    } else {
      setState(() => _poseIsCorrect = esCorrecta);
    }
  }

  void _startMainTimer(int segundos) {
    _sessionStarted = true;
    _currentCountdown = segundos;

    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_poseIsCorrect) return;

      setState(() => _currentCountdown--);

      if (_currentCountdown <= 0) {
        _finishSession();
      }
    });
  }

  void _finishSession() {
    _poseDetectionTimer.cancel();
    if (_sessionStarted) _mainTimer.cancel();
    _cameraController.dispose();
    _classifierHelper.close();
    setState(() => _sessionFinished = true);
  }

  @override
  void dispose() {
    _poseDetectionTimer.cancel();
    if (_sessionStarted) _mainTimer.cancel();
    _cameraController.dispose();
    _classifierHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pose = context.watch<YogaSessionViewModel>().selectedPose;

    return Scaffold(
      appBar: AppBar(title: const Text("Yoga")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFA9A8F2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cronómetro: ${_sessionStarted ? _currentCountdown : 'XX'}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  _poseIsCorrect ? "¡Vas bien!" : "Corrige la postura",
                  style: TextStyle(
                    color: _poseIsCorrect ? Colors.white : Colors.red[100],
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: _cameraController.value.isInitialized
                ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finishSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA9A8F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Finalizar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
