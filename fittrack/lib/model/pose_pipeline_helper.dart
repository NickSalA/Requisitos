import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../utils/image_utils.dart';

// Esta clase centraliza el pipeline de inferencia.
class PosePipelineHelper {
  final Interpreter moveNet;
  final Interpreter poseClassifier;

  PosePipelineHelper({required this.moveNet, required this.poseClassifier});

  // Toma una CameraImage, la preprocesa, corre movenet y el classifier, y retorna el resultado.
  Future<Map<String, dynamic>> inferFromCamera(img.Image cameraImage) async {
    // 1. Preprocesar la imagen (RGB y resize)
    img.Image inputImg = img.copyResize(cameraImage, width: 192, height: 192);

    // 2. Convertir a uint8 [1,192,192,3]
    var input = List.generate(
      1,
      (_) => List.generate(
        192,
        (y) => List.generate(192, (x) {
          final px = inputImg.getPixel(x, y);
          return [px.r, px.g, px.b];
        }),
      ),
    );

    // 3. Output keypoints movenet
    var outputKeypoints =
        List.generate(1, (_) => List.generate(17, (_) => List.filled(3, 0.0)));

    moveNet.run(input, outputKeypoints);

    // 4. Normalizar los keypoints (debes tener la función!)
    List<List<double>> landmarks =
        outputKeypoints[0].map<List<double>>((p) => [p[0], p[1]]).toList();
    var embedding = normalizeAndFlatten(landmarks);

    // 5. Inference con classifier
    // El modelo espera [1, 34]
    var classifierInput = [embedding];
    var classifierOutput =
        List.filled(4, 0.0); // Cambia NUM_CLASSES a lo que corresponda
    poseClassifier.run(classifierInput, [classifierOutput]);

    // 6. Analiza resultados
    int maxIdx = 0;
    double maxScore = classifierOutput[0];
    for (int i = 1; i < classifierOutput.length; i++) {
      if (classifierOutput[i] > maxScore) {
        maxScore = classifierOutput[i];
        maxIdx = i;
      }
    }
    // Devuelve keypoints, clase y score.
    return {
      'keypoints': outputKeypoints[0],
      'pose': List[maxIdx], // Define LABELS como una lista de tus clases.
      'confidence': maxScore,
    };
  }

  // --------
  // Tu función de normalización aquí (¡debes portarla desde Python!):
  // Aquí un ejemplo simple:
  List<double> normalizeAndFlatten(List<List<double>> keypoints) {
    // ... Normaliza los keypoints como lo hiciste en python y aplana a 34 floats ...
    // Debes replicar el mismo algoritmo que usaste en el entrenamiento (get_center_point, get_pose_size, etc).
    // Esto es CRUCIAL para que el classifier funcione bien.
    // Devuelve una lista de 34 floats.
    throw UnimplementedError();
  }
}
