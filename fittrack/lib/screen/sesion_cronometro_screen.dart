import 'package:flutter/material.dart';

class SesionCronometroScreen extends StatelessWidget {
  const SesionCronometroScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Aquí iría la lógica para iniciar el cronómetro
    // Por ahora, solo mostramos un mensaje de placeholder
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cronómetro"),
      ),
      body: Center(
        child: Text(
          "Aquí se iniciaría el cronómetro",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
