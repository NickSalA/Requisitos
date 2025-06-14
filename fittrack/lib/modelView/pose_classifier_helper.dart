import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:fittrack/model/inferer.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;
import 'package:fittrack/model/pose_inference_model.dart';

class PoseClassifierHelper {
  static const modelPath = 'assets/model/model.tflite';
  static const labelsPath = 'assets/model/class_names.txt';

  late final Interpreter interpreter;
  late final List<String> labels;
  late Tensor inputTensor;
  late Tensor outputTensor;
  late final IsolatePoseEstimator isolateInference;

  Future<void> _loadLabels() async {
    labels = (await rootBundle.loadString(labelsPath)).split('\n');
  }

  Future<void> _loadModel() async {
    final options = InterpreterOptions();
    if (Platform.isAndroid) options.addDelegate(XNNPackDelegate());
    if (Platform.isIOS) options.addDelegate(GpuDelegate());

    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;
  }

  Future<void> init() async {
    await _loadLabels();
    await _loadModel();
    isolateInference = IsolatePoseEstimator();
    await isolateInference.start();
  }

  Future<Map<String, dynamic>> inferFromCamera(CameraImage image) async {
    final port = ReceivePort();
    final model = PoseInferenceModel(
      cameraImage: image,
      isCamera: true,
      interpreterAddress: interpreter.address,
      labels: labels,
    )..responsePort = port.sendPort;

    isolateInference.sendPort.send(model);
    return await port.first;
  }

  Future<Map<String, dynamic>> inferFromImage(image_lib.Image image) async {
    final port = ReceivePort();
    final model = PoseInferenceModel(
      image: image,
      isCamera: false,
      interpreterAddress: interpreter.address,
      labels: labels,
    )..responsePort = port.sendPort;

    isolateInference.sendPort.send(model);
    return await port.first;
  }

  Future<void> close() async {
    await isolateInference.close();
  }
}
