import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modelView/yoga_provider.dart';
import '../../modelView/sesion_yoga_screen.dart';
import '../utils/keypoints_painter.dart';

class SesionYogaScreen extends StatelessWidget {
  const SesionYogaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pose = context.watch<YogaSessionViewModel>().selectedPose;
    final tiempoObjetivo = context.watch<YogaSessionViewModel>().tiempoObjetivo;

    return FutureBuilder<List<CameraDescription>>(
      future: availableCameras(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Usa la cámara frontal si existe, si no la trasera
        final camera = snapshot.data!.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => snapshot.data!.first,
        );

        return ChangeNotifierProvider(
          create: (_) => PoseSessionViewModel()
            ..initialize(
              camera,
              tiempoObjetivo,
              pose?.nombre ?? '',
            ),
          child: const _SesionYogaView(),
        );
      },
    );
  }
}

class _SesionYogaView extends StatelessWidget {
  const _SesionYogaView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PoseSessionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Yoga"),
        backgroundColor: const Color(0xFFA9A8F2),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Feedback y cronómetro, solo la info relevante
            Container(
              width: double.infinity,
              color: const Color(0xFFA9A8F2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cronómetro
                  Text(
                    "Cronómetro: ${vm.sessionStarted ? vm.countdown : 'XX'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Feedback
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
                            color: Colors.yellowAccent,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Cámara + keypoints (ocupa todo el espacio disponible)
            Expanded(
              child: Builder(
                builder: (context) {
                  if (!vm.cameraController.value.isInitialized) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final previewSize = vm.cameraController.value.previewSize;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(vm.cameraController),
                      if (vm.keypoints != null && previewSize != null)
                        CustomPaint(
                          painter: KeypointsPainter(
                            vm.keypoints!,
                            previewSize,
                          ),
                          size: Size.infinite,
                        ),
                    ],
                  );
                },
              ),
            ),

            // Botón finalizar (siempre visible)
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
      ),
    );
  }
}
