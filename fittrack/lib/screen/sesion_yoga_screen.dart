import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modelView/yoga_provider.dart';
import '../modelView/pose_session_view_model.dart';
import '../utils/keypoints_painter.dart';
import 'package:fittrack/screen/yoga_resultados.dart';

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
              pose?.imagenPath ?? '',
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
    if (vm.sessionFinished && vm.resumen != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final yoga = vm.resumen!;

        // Navega y luego libera VM al volver
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResumenSesionScreen(yoga: yoga),
          ),
        );
        if (vm.cameraController.value.isStreamingImages) {
          await vm.cameraController.stopImageStream();
        }
        await vm.cameraController.dispose();
        // IMPORTANTE: liberar recursos luego
        vm.dispose();
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yoga"),
        backgroundColor: const Color(0xFFA9A8F2),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Cámara + keypoints (ocupa todo el espacio disponible)
            Expanded(
              child: Builder(
                builder: (context) {
                  if (!vm.cameraController.value.isInitialized) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final camera = vm.cameraController.value;
                  final size = MediaQuery.of(context).size;
                  var scale =
                      size.aspectRatio * camera.previewSize!.aspectRatio;
                  if (scale < 1) scale = 1 / scale;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Camera con AspectRatio fijo 16:9
                      Center(
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: CameraPreview(vm.cameraController),
                        ),
                      ),
                      // Overlay keypoints alineados a 16:9
                      if (vm.keypoints != null)
                        Center(
                          child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: CustomPaint(
                              painter: KeypointsPainter(
                                vm.keypoints!,
                                // El size base de referencia también debe ser 16:9.
                                // Por ejemplo, Size(1920, 1080) o cualquier múltiplo de 16:9
                                const Size(1920, 1080),
                              ),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                      // Barra superior tipo feedback/crono (overlay)
                      Positioned(
                        left: 16,
                        right: 16,
                        top: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                                alpha: 124.0), // Fondo claro y opaco
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Cronómetro: ${vm.sessionStarted ? vm.countdown : 'XX'}",
                                      style: const TextStyle(
                                        color: Color(0xFFA9A8F2),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    vm.isPoseCorrect
                                        ? "¡Vas bien!"
                                        : "Corrige la postura",
                                    style: TextStyle(
                                      color: vm.isPoseCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              if (vm.feedback != null &&
                                  vm.feedback!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    vm.feedback!,
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Botón finalizar (ya existente abajo)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 24,
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
                    ],
                  );
                },
              ),
            ),

            // Botón finalizar (siempre visible)
          ],
        ),
      ),
    );
  }
}
