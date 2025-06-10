import 'dart:isolate';
import 'package:image/image.dart' as image_lib;
import 'package:camera/camera.dart';

class PoseInferenceModel {
  CameraImage? cameraImage;
  image_lib.Image? image;
  bool isCamera;
  int interpreterAddress;
  List<String> labels;
  late SendPort responsePort;

  PoseInferenceModel({
    this.cameraImage,
    this.image,
    required this.isCamera,
    required this.interpreterAddress,
    required this.labels,
  });

  bool isCameraFrame() {
    return cameraImage != null;
  }
}
