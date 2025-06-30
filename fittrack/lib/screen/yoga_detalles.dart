import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/yoga.dart';

class YogaDetailScreen extends StatelessWidget {
  final Yoga yoga;

  const YogaDetailScreen({super.key, required this.yoga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('¿Para qué sirve?'),
            const SizedBox(height: 15),
            _buildDescriptionText(yoga.descripcion),
            const SizedBox(height: 30),
            _buildSectionTitle('Descripción'),
            const SizedBox(height: 15),
            _buildDescriptionText(_getDescripcionExtendida(yoga.tipo)),
          ],
        ),
      ),
    );
  }

  /// AppBar personalizado con imagen y nombre
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(180),
      child: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFA9A8F2),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(yoga.imagenPath, height: 80),
              const SizedBox(height: 10),
              Text(
                yoga.nombre,
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Título de cada sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Texto general con descripción
  Widget _buildDescriptionText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }

  /// Descripción extendida por tipo de pose
  String _getDescripcionExtendida(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'goddess':
        return 'La pose de la diosa fortalece la parte inferior del cuerpo, especialmente muslos y glúteos. Además, abre las caderas y mejora la estabilidad emocional.';
      case 'tree':
        return 'La pose del árbol desarrolla el equilibrio, la coordinación y la fuerza en las piernas. También promueve la concentración y la calma interior.';
      case 'warrior':
        return 'La pose del guerrero fortalece piernas y brazos, aumenta la resistencia y mejora la postura. Es ideal para desarrollar confianza y enfoque.';
      case 'downdog':
        return 'La postura del perro boca abajo estira y fortalece todo el cuerpo. Calma la mente y mejora la circulación. Es una de las poses más usadas para relajación.';
      default:
        return 'Esta pose de yoga aporta múltiples beneficios físicos y mentales, ayudando a mejorar tu bienestar general.';
    }
  }
}
