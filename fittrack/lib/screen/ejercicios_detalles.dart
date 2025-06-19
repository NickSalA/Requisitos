import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/ejercicio.dart';

class EjercicioDetailScreen extends StatefulWidget {
  final Ejercicio ejercicio;

  const EjercicioDetailScreen({super.key, required this.ejercicio});

  @override
  State<EjercicioDetailScreen> createState() => _EjercicioDetailScreenState();
}

class _EjercicioDetailScreenState extends State<EjercicioDetailScreen> {
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _repeticionesController = TextEditingController();
  final TextEditingController _descansoController = TextEditingController();

  @override
  void dispose() {
    _seriesController.dispose();
    _repeticionesController.dispose();
    _descansoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
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
                Image.asset(widget.ejercicio.imagenPath, height: 80),
                const SizedBox(height: 10),
                Text(
                  widget.ejercicio.nombre,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField("Series:", _seriesController),
            const SizedBox(height: 20),
            _buildInputField("Repeticiones:", _repeticionesController),
            const SizedBox(height: 20),
            _buildInputField("Descanso (minutos):", _descansoController),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                final series = _seriesController.text;
                final repeticiones = _repeticionesController.text;
                final descanso = _descansoController.text;

                if (series.isEmpty ||
                    repeticiones.isEmpty ||
                    descanso.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Por favor, completa todos los campos.")),
                  );
                  return;
                }
                setState(() {
                  widget.ejercicio.series =
                      int.tryParse(series) ?? widget.ejercicio.series;
                  widget.ejercicio.repeticiones = int.tryParse(repeticiones) ??
                      widget.ejercicio.repeticiones;
                  widget.ejercicio.descanso =
                      int.tryParse(descanso) ?? widget.ejercicio.descanso;
                });
                print(
                    "Series: $series, Repeticiones: $repeticiones, Descanso: $descanso");
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA9A8F2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                '¡Listo!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF0F0F0),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
