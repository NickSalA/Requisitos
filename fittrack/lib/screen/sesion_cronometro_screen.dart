import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fittrack/modelView/cronometro_view_model.dart';
import 'cronometro_resultados.dart';
import 'package:fittrack/model/pose_helper.dart';

class SesionCronometroScreen extends StatelessWidget {
  const SesionCronometroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PoseCronometroSessionViewModel>();
    final poseAsset = vm.sesion.posesPath[vm.index];
    final poses = vm.sesion.posesPath;
    if (poses.isEmpty) {
      // Si por algún motivo no hay poses, lo indicamos:
      return Scaffold(
        body: Center(
          child: Text(
            'No hay poses disponibles para esta sesión',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    // llamamos a registerOnFinish una sola vez con didChangeDependencies
    // para evitar bucles; aquí, usando Provider.of with listen: false
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PoseCronometroSessionViewModel>().registerOnFinish(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              // Reutiliza la misma instancia del VM que ya está activa:
              value: context.read<PoseCronometroSessionViewModel>(),
              child: const CronometroResultadosScreen(),
            ),
          ),
        );
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // … barra superior …
            Expanded(child: Center(child: Image.asset(poseAsset))),
            Text(vm.isPrep ? 'Prepárate…' : vm.sesion.nombrePose(vm.index)),
            const SizedBox(height: 8),
            Text('${vm.secondsLeft}',
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (!vm.isPrep)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ctrlBtn(Icons.arrow_back,
                      onTap: () => vm.previous(), enabled: vm.index > 0),
                  _ctrlBtn(
                    vm.isPaused ? Icons.play_arrow : Icons.pause,
                    big: true,
                    onTap: vm.togglePause,
                  ),
                  _ctrlBtn(Icons.arrow_forward, onTap: vm.next),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _ctrlBtn(IconData icon,
          {required VoidCallback onTap,
          bool big = false,
          bool enabled = true}) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.3,
          child: Container(
            width: big ? 72 : 52,
            height: big ? 72 : 52,
            decoration: BoxDecoration(
              color: big ? const Color(0xFF3498FF) : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: big ? 40 : 26),
          ),
        ),
      );
}
