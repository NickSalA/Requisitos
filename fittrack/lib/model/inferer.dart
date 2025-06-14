import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:fittrack/utils/image_utils.dart';
import 'pose_inference_model.dart';
import 'dart:math';

class IsolatePoseEstimator {
  static const String _debugName = 'ISOLATE_POSE_ESTIMATOR';
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );
    _sendPort = await _receivePort.first;
  }

  Future<void> close() async {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    // Cargar modelo clasificador y etiquetas
    final classifier = await rootBundle.load('assets/model/model.tflite');
    Interpreter.fromBuffer(classifier.buffer.asUint8List());
    final labelsTxt =
        await rootBundle.loadString('assets/model/class_names.txt');
    final labels = labelsTxt.split('\n');

    await for (final PoseInferenceModel model in port) {
      image_lib.Image? img;
      if (model.isCamera && model.cameraImage != null) {
        img = ImageUtils.convertCameraImage(model.cameraImage!);
      } else {
        img = model.image;
      }

      if (img == null) {
        model.responsePort.send({'error': 'No image data'});
        continue;
      }

      var resized = image_lib.copyResize(img, width: 192, height: 192);
      if (Platform.isAndroid && model.isCamera) {
        resized = image_lib.copyRotate(resized, angle: 90);
      }

      final inputTensor = List.generate(
        1,
        (_) => List.generate(
          192,
          (y) => List.generate(192, (x) {
            final px = resized.getPixel(x, y);
            return [px.r / 255.0, px.g / 255.0, px.b / 255.0];
          }),
        ),
      );

      final outputs = List.generate(
          1,
          (_) => List.generate(
              1, (_) => List.generate(17, (_) => List.filled(3, 0.0))));

      final interpreter = Interpreter.fromAddress(model.interpreterAddress);
      interpreter.run(inputTensor, outputs);

      final keypoints = outputs[0][0];

      // Preprocesamiento (centrar, normalizar, aplanar)
      final hipsCenter = _midpoint(keypoints[11], keypoints[12]);
      final poseSize =
          keypoints.map((k) => _distance(k, hipsCenter)).reduce(max);
      final normalized = keypoints
          .map((k) => [
                (k[0] - hipsCenter[0]) / poseSize,
                (k[1] - hipsCenter[1]) / poseSize
              ])
          .toList();
      final embedding = normalized.expand((pair) => pair).toList();

      // Clasificación
      final classOutput = List.filled(labels.length, 0.0);
      classifier.run([embedding], [classOutput]);

      final maxIndex =
          classOutput.indexWhere((e) => e == classOutput.reduce(max));
      final posture = labels[maxIndex];
      final confidence = classOutput[maxIndex];

      // Feedback por postura
      final feedback = _evaluarFeedback(posture, normalized);

      model.responsePort.send({
        'keypoints': keypoints,
        'posture': posture,
        'confidence': confidence,
        'feedbackParteMal': feedback,
      });
    }
  }

  static List<double> _midpoint(List k1, List k2) {
    return [(k1[0] + k2[0]) / 2.0, (k1[1] + k2[1]) / 2.0];
  }

  static double _distance(List p1, List p2) {
    return sqrt(pow(p1[0] - p2[0], 2) + pow(p1[1] - p2[1], 2));
  }

  static String? _evaluarFeedback(String posture, List<List<double>> kps) {
    switch (posture.toLowerCase()) {
      case 'cobra':
        if (kps[0][1] > kps[5][1]) return 'Levanta más la cabeza';
        break;
      case 'tree':
        if ((kps[15][0] - kps[11][0]).abs() > 0.3)
          return 'Apoya mejor el pie en el muslo';
        break;
      case 'downdog':
        if (kps[5][1] < kps[11][1]) return 'Baja más las caderas';
        break;
      case 'warrior2':
        if ((kps[7][1] - kps[5][1]) > 0.15) return 'Codo izquierdo caído';
        if ((kps[8][1] - kps[6][1]) > 0.15) return 'Codo derecho caído';
        break;
    }
    return null;
  }
}
