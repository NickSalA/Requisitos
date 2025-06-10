// ejercicio_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/yoga.dart';

class YogaDetailScreen extends StatelessWidget {
  final Yoga yoga;

  const YogaDetailScreen({super.key, required this.yoga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(yoga.nombre),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Detalles de la postura',
              style: GoogleFonts.poppins(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Nombre: ${yoga.nombre}',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            Text(
              'Descripción: ${yoga.descripcion}',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            // Puedes agregar más detalles aquí
          ],
        ),
      ),
    );
  }
}