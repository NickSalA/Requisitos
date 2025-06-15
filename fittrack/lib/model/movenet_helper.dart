// lib/model/movenet_helper.dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as image_lib;
import 'package:flutter/foundation.dart';

class MoveNetHelper {
  late Interpreter interpreter;

  Future<void> init() async {
    interpreter = await Interpreter.fromAsset('assets/model/movenet32.tflite');
    var inputType = interpreter.getInputTensors().first.type;
    debugPrint('Tipo de input del modelo: $inputType');
  }

  // Convierte image_lib.Image a keypoints (List<List<double>>)
  List<List<double>> infer(image_lib.Image image) {
    final resized = image_lib.copyResize(image, width: 256, height: 256);

    final input = List.generate(
      1,
      (_) => List.generate(
        256,
        (y) => List.generate(
          256,
          (x) {
            final px = resized.getPixel(x, y);
            return [px.r / 255.0, px.g / 255.0, px.b / 255.0];
          },
        ),
      ),
    );

    final output = List.generate(
        1,
        (_) => List.generate(
            1, (_) => List.generate(17, (_) => List.filled(3, 0.0))));
    interpreter.run(input, output);

    // Devuelve una lista de 17 keypoints (x, y, conf)
    return List<List<double>>.from(
      output[0][0].map((item) => List<double>.from(item)),
    );
  }

  void close() => interpreter.close();
}
