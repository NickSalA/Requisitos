import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';

class PoseClassifierHelper {
  late Interpreter interpreter;

  Future<void> init() async {
    interpreter = await Interpreter.fromAsset(
      'assets/model/pose_classifier.tflite',
    );
    var inputType = interpreter.getInputTensors().first.type;
    debugPrint('Tipo de input del modelo: $inputType');
  }

  int classify(List<double> embedding) {
    // embedding = [34] (normalizados)
    final input = [embedding];
    final output = List.filled(4, 0.0); // 4 clases, cambia según tu modelo
    interpreter.run(input, [output]);
    // Devuelve el índice de la clase con mayor probabilidad
    return output.indexOf(output.reduce((a, b) => a > b ? a : b));
  }

  void close() => interpreter.close();
}
