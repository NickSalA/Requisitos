import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PoseService {
  late Interpreter _interpreter;

  PoseService._();

  static Future<PoseService> create() async {
    final instance = PoseService._();
    instance._interpreter = await Interpreter.fromAsset('model/movenet16.tflite');
    return instance;
  }

  /// Procesa un frame de cámara y retorna los keypoints [17][3]
  List<List<double>> processCameraImage(CameraImage image) {
    // Convertir el frame a una entrada de 1x192x192x3
    final input = _preprocess(image);

    // Crear salida [1][17][3]
    final output = List.generate(1, (_) =>
        List.generate(17, (_) => List.filled(3, 0.0)));

    _interpreter.run(input, output);

    return output[0];
  }

  /// Preprocesamiento simple: convierte solo el canal Y a formato esperado por el modelo
  List<List<List<List<double>>>> _preprocess(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final bytes = yPlane.bytes;

    // Resize a 192x192 (el input del modelo)
    const inputSize = 192;
    final resized = List.generate(
      inputSize,
          (y) => List.generate(
        inputSize,
            (x) => List.generate(
          3,
              (c) => bytes[(y * width + x) % bytes.length] / 255.0, // Normalizar
        ),
      ),
    );

    return [resized];
  }

  void close() => _interpreter.close();
}
