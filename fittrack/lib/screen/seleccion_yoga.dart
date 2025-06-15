// lib/features/yoga_session/view/seleccion_yoga_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../modelView/yoga_provider.dart';
import 'sesion_yoga_screen.dart'; // Esta será la pantalla que usa cámara

class SeleccionYogaScreen extends StatefulWidget {
  const SeleccionYogaScreen({super.key});

  @override
  State<SeleccionYogaScreen> createState() => _SeleccionYogaScreenState();
}

class _SeleccionYogaScreenState extends State<SeleccionYogaScreen> {
  final TextEditingController _tiempoController = TextEditingController();

  @override
  void dispose() {
    _tiempoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yoga = context.watch<YogaSessionViewModel>().selectedPose;
    if (yoga == null) {
      return const Scaffold(
        body: Center(child: Text("No se seleccionó ninguna postura")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Yoga"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              )
            ],
          ),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header morado con icono
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFA9A8F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Image.asset(
                      yoga.imagenPath,
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      yoga.nombre,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tiempo:",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tiempoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Duración en segundos",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFA9A8F2), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFFA9A8F2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final input = _tiempoController.text.trim();
                    final tiempo = int.tryParse(input);

                    if (tiempo != null && tiempo > 0) {
                      context
                          .read<YogaSessionViewModel>()
                          .setTiempoObjetivo(tiempo);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SesionYogaScreen(), // a implementar
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ingresa un tiempo válido (> 0)"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA9A8F2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "¡Listo!",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
