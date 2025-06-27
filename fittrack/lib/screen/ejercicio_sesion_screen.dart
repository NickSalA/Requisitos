import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fittrack/utils/keypoints_painter.dart';
import 'package:fittrack/modelView/ejercicio_session_view_model.dart';
import 'package:fittrack/utils/pose_service.dart';
import 'package:fittrack/model/pose_pipeline_ejercicio_helper.dart';
import 'package:provider/provider.dart';

class EjercicioSesionScreen extends StatefulWidget {
  final String nombreEjercicio;

  const EjercicioSesionScreen({required this.nombreEjercicio, super.key});

  @override
  State<EjercicioSesionScreen> createState() => _EjercicioSesionScreenState();
}

class _EjercicioSesionScreenState extends State<EjercicioSesionScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;

  PoseService? _poseService;
  PosePipelineEjercicioHelper? _pipeline;
  bool _isDetecting = false;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePoseSystem();
  }

  Future<void> _initializePoseSystem() async {
    _cameras = await availableCameras();
    await _setupCamera(_selectedCameraIndex);

    _poseService = await PoseService.create();
    final viewModel = Provider.of<EjercicioSessionViewModel>(context, listen: false);
    _pipeline = PosePipelineEjercicioHelper(viewModel);

    _cameraController.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final keypoints = _poseService!.processCameraImage(image);
        _pipeline!.process(keypoints);
      } catch (e) {
        print("Error en procesamiento de imagen: $e");
      } finally {
        _isDetecting = false;
      }
    });

    setState(() => _isCameraInitialized = true);
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_cameraController.value.isStreamingImages) {
      await _cameraController.stopImageStream();
    }
    _cameraController = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _cameraController.initialize();
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isCameraInitialized = false;
    });

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCamera(_selectedCameraIndex);

    _cameraController.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final keypoints = _poseService!.processCameraImage(image);
        _pipeline!.process(keypoints);
      } catch (e) {
        print("Error en procesamiento tras cambio de cámara: $e");
      } finally {
        _isDetecting = false;
      }
    });

    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController.stopImageStream();
    _cameraController.dispose();
    _poseService?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EjercicioSessionViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Colors.deepPurple.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Serie: ${vm.serieActual}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Repetición: ${vm.repeticionActual}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Expanded(
                  child: Text(
                    vm.mensajeFeedback,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: _isCameraInitialized
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_cameraController),
                  if (_cameraController.value.previewSize != null)
                    Consumer<EjercicioSessionViewModel>(
                      builder: (_, vm, __) {
                        final keypoints = vm.keypointsActuales;
                        if (keypoints.isEmpty) return const SizedBox.shrink();
                        return CustomPaint(
                          painter: KeypointsPainter(
                            keypoints,
                            _cameraController.value.previewSize!,
                          ),
                        );
                      },
                    ),
                ],
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade200,
                minimumSize: const Size(double.infinity, 40),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Finalizar"),
            ),
          ),
        ],
      ),
      floatingActionButton: _isCameraInitialized
          ? FloatingActionButton(
        onPressed: _switchCamera,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.cameraswitch),
      )
          : null,
    );
  }
}
