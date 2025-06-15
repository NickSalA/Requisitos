import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import '../utils/image_utils.dart'; // <-- La clase que mostraste
import '../utils/normalize_keypoints.dart'; // <-- Normalización + embedding
import '../model/movenet_helper.dart';
import '../model/pose_helper.dart';
import '../model/pose_pipeline_helper.dart';

class PoseSessionViewModel extends ChangeNotifier {
  late CameraController _cameraController;
  late MoveNetHelper movenetHelper;
  late PoseClassifierHelper poseClassifierHelper;

  final int _countdown = 0;
  bool _poseCorrect = false;
  final bool _sessionStarted = false;
  bool _sessionFinished = false;
  String? _currentPose;
  int? _currentPoseIdx;
  double? _confidence;
  String? _feedback;
  List<List<double>>? _keypoints;

  bool _processing = false;

  // ---- Getters para la UI ----
  CameraController get cameraController => _cameraController;
  bool get isPoseCorrect => _poseCorrect;
  int get countdown => _countdown;
  bool get sessionStarted => _sessionStarted;
  bool get sessionFinished => _sessionFinished;
  String? get currentPose => _currentPose;
  double? get confidence => _confidence;
  String? get feedback => _feedback;
  List<List<double>>? get keypoints => _keypoints;
  late PosePipelineHelper posePipelineHelper;
  // Mapea el índice a nombre de la pose (ajusta con tus labels reales)
  final List<String> poseLabels = ["Cobra", "Downdog", "Tree", "Warrior2"];
  Future<void> initialize(
      CameraDescription camera, int tiempoObjetivo, String expectedPose) async {
    _pipelineHelper = PosePipelineHelper(
      moveNet: await Interpreter.fromAsset('assets/model/movenet.tflite'),
      poseClassifier:
          await Interpreter.fromAsset('assets/model/pose_classifier.tflite'),
    );
    _cameraController = CameraController(camera, ResolutionPreset.low);
    await _cameraController.initialize();

    movenetHelper = MoveNetHelper();
    poseClassifierHelper = PoseClassifierHelper();
    await movenetHelper.init();
    await poseClassifierHelper.init();

    // Comienza el stream de la cámara
    await _cameraController.startImageStream((CameraImage image) async {
      if (_processing) return;
      _processing = true;
      try {
        final img = ImageUtils.convertCameraImage(image);
        if (img == null) {
          _processing = false;
          return;
        }

        // ---- MoveNet: obtiene keypoints ----
        final keypoints = movenetHelper.infer(img); // [ [x, y, score], ... ]
        _keypoints = keypoints;

        // ---- Normalización ----
        final normalized = normalizeKeypoints(keypoints);
        final embedding = getEmbedding(normalized);

        // ---- Clasificación de la pose ----
        final poseIdx = poseClassifierHelper.classify(embedding);
        _currentPoseIdx = poseIdx;
        _currentPose = poseLabels[poseIdx]; // O tus propios nombres

        // ---- (Opcional) Obtener "confianza" si tu modelo lo permite ----
        // double? conf = ... // según tu modelo de clasificación

        // ---- Feedback personalizado: ajusta con tu lógica ----
        // Aquí puedes detectar si la pose es la esperada
        final expectedIdx = poseLabels.indexWhere(
            (label) => label.toLowerCase() == expectedPose.toLowerCase());

        _poseCorrect = poseIdx == expectedIdx;

        // Feedback básico: muestra nombre de la pose detectada y si es correcta
        _feedback = _poseCorrect ? "¡Perfecto!" : "Corrige la postura";

        notifyListeners();
      } catch (e) {
        debugPrint('Error al procesar frame: $e');
      } finally {
        _processing = false;
      }
    });
  }

  // ---- Métodos para control de sesión (puedes ajustar según tu lógica de yoga) ----

  void finishSession() {
    _cameraController.dispose();
    movenetHelper.close();
    poseClassifierHelper.close();
    _sessionFinished = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    movenetHelper.close();
    poseClassifierHelper.close();
    super.dispose();
  }
}
