import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/modo_cronometro.dart';

class CronometroDetailScreen extends StatelessWidget {
  const CronometroDetailScreen({super.key, required this.cronometro});

  final ModoCronometro cronometro;

  @override
  Widget build(BuildContext context) {
    debugPrint('Debug – posesPath contiene: ${cronometro.posesPath}');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA9A8F2),
        elevation: 0,
        title: Text(
          cronometro.nombre.trim(),
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Descripción
            Text(
              cronometro.descripcion,
              style: GoogleFonts.poppins(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // Cuadrícula 2x2 con las cuatro poses
            Expanded(
              child: GridView.builder(
                itemCount: cronometro.posesPath.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    cronometro.posesPath[i],
                    fit: BoxFit.cover,
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
