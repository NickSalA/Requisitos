import 'dart:math';

import 'package:camera/camera.dart';
import 'package:fittrack/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../model/poses.dart'; // Aquí pones tus funciones manuales
import 'package:tflite_flutter/tflite_flutter.dart';

class PoseClassificationResult {
  final List<List<double>> keypoints; // [17][3] [x,y,score]
  final String clase;
  final double confianza; // puedes poner 1.0 o score promedio
  final String? feedback;

  PoseClassificationResult({
    required this.keypoints,
    required this.clase,
    required this.confianza,
    this.feedback,
  });
}

class PosePipelineHelper {
  static const String movenetPath = 'assets/model/movenet16.tflite';

  late final Interpreter _movenet;
  bool _initialized = false;

  Future<void> init() async {
    _movenet = await Interpreter.fromAsset(movenetPath);
    _initialized = true;
  }

  Future<PoseClassificationResult> classifyFromCamera(
      CameraImage image, String selectedPose) async {
    if (!_initialized) throw Exception('Pipeline no inicializado');

    try {
      img.Image? rgbImage = _convertCameraImageToImage(image);
      if (rgbImage == null) throw Exception('No se pudo convertir la imagen');

      img.Image inputMovenet =
          img.copyResize(rgbImage, width: 192, height: 192);

      var movenetInput = List.generate(
          1,
          (_) => List.generate(
              192,
              (y) => List.generate(192, (x) {
                    final pixel = inputMovenet.getPixel(x, y);
                    return [pixel.r, pixel.g, pixel.b];
                  })));

      var keypointsOutput = List.generate(
          1,
          (_) => List.generate(
              1, (_) => List.generate(17, (_) => List.filled(3, 0.0))));

      _movenet.run(movenetInput, keypointsOutput);
      debugPrint(' Keypoints extraidos: ${keypointsOutput[0][0]}');
      final keypoints = List<List<double>>.generate(
          17, (i) => List<double>.from(keypointsOutput[0][0][i]));
      debugPrint('Keypoints con score: ${keypoints.map((k) => k[2]).toList()}');
      final confiables = keypoints.where((k) => k[2] > 0.4).toList();
      if (confiables.length < 12) {
        return PoseClassificationResult(
          keypoints: keypoints,
          clase: 'no_pose',
          confianza: 0.0,
          feedback:
              "Por favor, ajusta la cámara para que tu cuerpo entero sea visible.",
        );
      }
      final xyKeypoints = keypoints.map((kpt) => [kpt[0], kpt[1]]).toList();

      debugPrint('🔄 Keypoints normalizados: $xyKeypoints');
      final bool isCorrect =
          isPoseSelectedCorrect(xyKeypoints, selectedPose, debug: true);
      String poseClass = isCorrect ? selectedPose.toLowerCase() : 'unknown';
      String feedback = isCorrect
          ? getFeedback(selectedPose, xyKeypoints)
          : "Ajusta tu alineación para la postura $selectedPose.";
      final confianza = isCorrect ? 1.0 : 0.0;
      return PoseClassificationResult(
        keypoints: keypoints,
        clase: poseClass,
        confianza: confianza,
        feedback: feedback,
      );
    } catch (e, stack) {
      debugPrint("Error en classifyFromCamera: $e\n$stack");
      // Devuelve un resultado de error, no crashees la app
      return PoseClassificationResult(
        keypoints: [],
        clase: 'no_pose',
        confianza: 0.0,
        feedback: 'Error interno del modelo: $e',
      );
    }
  }

  img.Image? _convertCameraImageToImage(CameraImage cameraImage) {
    return ImageUtils.convertCameraImage(cameraImage);
  }

  void dispose() {
    if (_initialized) {
      _movenet.close();
    }
  }

  void printKeypoints(List<List<double>> kpts) {
    for (int i = 0; i < kpts.length; i++) {
      debugPrint(
          "KP $i: x=${kpts[i][0].toStringAsFixed(3)}, y=${kpts[i][1].toStringAsFixed(3)}");
    }
  }
}
