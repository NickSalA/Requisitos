import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modelView/yoga_provider.dart';
import '../../modelView/sesion_yoga_screen.dart';

class SesionYogaScreen extends StatefulWidget {
  const SesionYogaScreen({super.key});
  @override
  State<SesionYogaScreen> createState() => _SesionYogaScreenState();
}

class _SesionYogaScreenState extends State<SesionYogaScreen> {
  PoseSessionViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    // Si tienes el pose y tiempo en el Provider global, úsalo aquí:
    final pose = context.read<YogaSessionViewModel>().selectedPose;
    final tiempo = context.read<YogaSessionViewModel>().tiempoObjetivo;

    final vm = PoseSessionViewModel();
    await vm.initialize(camera, tiempo, pose?.nombre ?? '');
    setState(() {
      _viewModel = vm;
    });
  }

  @override
  void dispose() {
    _viewModel?.finishSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null ||
        !_viewModel!.cameraController.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: const _SesionYogaView(),
    );
  }
}

class _SesionYogaView extends StatelessWidget {
  const _SesionYogaView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PoseSessionViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Yoga")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFA9A8F2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cronómetro: ${vm.sessionStarted ? vm.countdown : 'XX'}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      vm.isPoseCorrect ? "¡Vas bien!" : "Corrige la postura",
                      style: TextStyle(
                        color:
                            vm.isPoseCorrect ? Colors.white : Colors.red[100],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!vm.isPoseCorrect && vm.feedback != null)
                      Text(
                        vm.feedback!,
                        style: const TextStyle(
                            color: Colors.yellowAccent, fontSize: 14),
                      ),
                    // DEBUG log:
                    if (vm.keypoints != null)
                      Text(
                        'DEBUG: KP ${vm.keypoints!.length} - ${vm.currentPose ?? "?"} (${(vm.confidence ?? 0.0).toStringAsFixed(2)})',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.deepPurple),
                      ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: vm.cameraController.value.isInitialized
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(vm.cameraController),
                      if (vm.keypoints != null)
                        CustomPaint(
                          painter: KeypointsPainter(vm.keypoints!,
                              vm.cameraController.value.previewSize),
                          size: Size.infinite,
                        ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.finishSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA9A8F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Finalizar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
