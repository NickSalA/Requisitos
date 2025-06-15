import 'package:camera/camera.dart';
import 'package:fittrack/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../utils/normalize_keypoints.dart'; // Debe contener la función normalizeKeypoints

class PoseClassificationResult {
  final List<List<double>> keypoints; // [17][3] [x,y,score]
  final String clase;
  final double confianza;
  final String? feedback;

  PoseClassificationResult({
    required this.keypoints,
    required this.clase,
    required this.confianza,
    this.feedback,
  });
}

class PosePipelineHelper {
  // Paths a tus modelos
  static const String movenetPath = 'assets/model/movenet16.tflite';
  static const String classifierPath = 'assets/model/pose_classifier.tflite';
  static const String classNamesPath = 'assets/model/class_names.txt';

  late final Interpreter _movenet;
  late final Interpreter _classifier;
  late final List<String> _classNames;
  bool _initialized = false;

  Future<void> init() async {
    // Carga modelos
    _movenet = await Interpreter.fromAsset(movenetPath);
    _classifier = await Interpreter.fromAsset(classifierPath);

    // Carga nombres de clases
    _classNames = (await rootBundle.loadString(classNamesPath)).split('\n');

    _initialized = true;
  }

  /// Procesa un frame de cámara, devuelve keypoints, clase, confianza y feedback
  Future<PoseClassificationResult> classifyFromCamera(CameraImage image) async {
    debugPrint('🚦 Pipeline: inicio de procesamiento');
    if (!_initialized) throw Exception('Pipeline no inicializado');

    // 1. Convertir CameraImage a imagen RGB (usa tu propio ImageUtils si prefieres)
    img.Image? rgbImage = _convertCameraImageToImage(image);
    debugPrint('🎨 Imagen convertida a RGB: ${rgbImage != null}');
    if (rgbImage == null) throw Exception('No se pudo convertir la imagen');

    // 2. Resize a 256x256 (Thunder) o 192x192 (Lightning), según el modelo
    img.Image inputMovenet = img.copyResize(rgbImage, width: 192, height: 192);
    debugPrint('📦 Preparando input para MoveNet');
    // 3. Prepara input para Movenet (uint8 [1,256,256,3])
    var movenetInput = List.generate(
        1,
        (_) => List.generate(
            192,
            (y) => List.generate(192, (x) {
                  final pixel = inputMovenet.getPixel(x, y);
                  return [pixel.r, pixel.g, pixel.b];
                })));

    // 4. Output tensor para keypoints [1,1,17,3]
    var keypointsOutput = List.generate(
        1,
        (_) => List.generate(
            1, (_) => List.generate(17, (_) => List.filled(3, 0.0))));

    _movenet.run(movenetInput, keypointsOutput);
    debugPrint('✅ MoveNet ejecutado');
    // 5. Extraer keypoints [17][3]
    final keypoints = List<List<double>>.generate(
        17, (i) => List<double>.from(keypointsOutput[0][0][i]));
    debugPrint('📍 Keypoints extraidos: $keypoints');

    // 6. Normalizar keypoints (usa tu normalizador propio)
    final normalized = normalizeKeypoints(keypoints);
    debugPrint('🔄 Keypoints normalizados: $normalized');
    // 7. Input para pose_classifier ([1, 34] si es 17 puntos x 2)
    final classifierInput = [
      normalized.expand((k) => [k[0], k[1]]).toList()
    ];
    debugPrint('📊 Input para clasificador: $classifierInput');
    // 8. Output tensor ([1, num_classes])
    var classifierOutput =
        List.generate(1, (_) => List.filled(_classNames.length, 0.0));

    _classifier.run(classifierInput, classifierOutput);
    debugPrint('✅ Clasificador ejecutado');
    // 9. Obtener predicción final
    final scores = classifierOutput[0];
    int maxIdx = 0;
    double maxScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIdx = i;
      }
    }

    final String clase = _classNames[maxIdx];
    final double confianza = maxScore;

    // 10. Feedback (opcional)
    String? feedback;
    // Puedes poner reglas de feedback aquí, ej:
    // if (normalized[5][1] < normalized[7][1]) feedback = 'Brazo izquierdo bajo';
    if (clase.toLowerCase().contains('Cobra')) {
      feedback = '¡Buena postura de Cobra!';
    } else if (clase.toLowerCase().contains('Tree')) {
      feedback = 'Mantén el equilibrio en el Árbol.';
    } else if (clase.toLowerCase().contains('Warrior2')) {
      feedback = 'Excelente postura de Guerrero.';
    } else if (normalized[5][1] < normalized[7][1]) {
      feedback = 'Asegúrate de que ambos brazos estén alineados.';
    } else if (normalized[11][1] > normalized[12][1]) {
      feedback = 'Alinea tus caderas correctamente.';
    } else if (normalized[0][0] < -0.5 || normalized[0][0] > 0.5) {
      feedback = 'Mantén la cabeza centrada sobre los hombros.';
    } else {
      feedback = 'Postura desconocida, revisa tu alineación.';
    }
    debugPrint(
        '🔍 Resultado final: clase=$clase, confianza=$confianza, feedback=$feedback');
    return PoseClassificationResult(
      keypoints: keypoints,
      clase: clase,
      confianza: confianza,
      feedback: feedback,
    );
  }

  img.Image? _convertCameraImageToImage(CameraImage cameraImage) {
    return ImageUtils.convertCameraImage(cameraImage);
  }

  void dispose() {
    _movenet.close();
    _classifier.close();
  }
}

// NOTA: globalContext! debe ser un BuildContext global. Si usas GetX, Get.context.
// O mejor: pasa el AssetBundle como argumento en init().
