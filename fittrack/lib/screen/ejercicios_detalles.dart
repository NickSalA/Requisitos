// ejercicio_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/ejercicio.dart';

class EjercicioDetailScreen extends StatelessWidget {
  final Ejercicio ejercicio;

  const EjercicioDetailScreen({super.key, required this.ejercicio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ejercicio.nombre),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Detalles del Ejercicio',
              style: GoogleFonts.poppins(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Nombre: ${ejercicio.nombre}',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            Text(
              'Descripción: ${ejercicio.descripcion}',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            // Puedes agregar más detalles aquí
          ],
        ),
      ),
    );
  }
}