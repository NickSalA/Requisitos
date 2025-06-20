import 'package:flutter/material.dart';
import 'package:fittrack/model/yoga.dart';

class ResumenSesionScreen extends StatelessWidget {
  final Yoga yoga;

  const ResumenSesionScreen({super.key, required this.yoga});

  @override
  Widget build(BuildContext context) {
    final double porcentaje =
        (yoga.duractionCorrecta / yoga.duracion * 100).clamp(0, 100);

    return Scaffold(
      backgroundColor: const Color(0xFFA9A8F2),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "¡Sesión Completada!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Porcentaje animado en círculo
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: porcentaje),
                duration: const Duration(seconds: 1),
                builder: (context, value, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: value / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        "${value.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Caja de resumen
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🧘 Postura: ${yoga.nombre}",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("⏱️ Duración total: ${yoga.duracion} s",
                        style: const TextStyle(fontSize: 18)),
                    Text("✅ Correcto: ${yoga.duractionCorrecta} s",
                        style: const TextStyle(fontSize: 18)),
                    Text("❌ Incorrecto: ${yoga.duracionIncorrecta} s",
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Volver al inicio",
                  style: TextStyle(
                    color: Color(0xFFA9A8F2),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
