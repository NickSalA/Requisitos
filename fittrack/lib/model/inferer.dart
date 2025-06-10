import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as image_lib;
import 'pose_inference_model.dart';
import 'package:fittrack/utils/image_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

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
                  })));

      final outputs = {
        0: List.generate(1,
            (_) => List.generate(17, (_) => List.filled(3, 0.0))), // keypoints
        1: List.filled(model.labels.length, 0.0), // class scores
      };

      final interpreter = Interpreter.fromAddress(model.interpreterAddress);
      interpreter.runForMultipleInputs([inputTensor], outputs);

      final keypoints = outputs[0];
      final classProbs = outputs[1] as List<double>;

      final maxIndex =
          classProbs.indexOf(classProbs.reduce((a, b) => a > b ? a : b));
      final posture = model.labels[maxIndex];
      final confidence = classProbs[maxIndex];

      model.responsePort.send({
        'keypoints': keypoints,
        'posture': posture,
        'confidence': confidence,
      });
    }
  }
}
