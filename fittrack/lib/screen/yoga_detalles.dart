import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/yoga.dart';

class YogaDetailScreen extends StatefulWidget {
  final Yoga yoga;

  const YogaDetailScreen({super.key, required this.yoga});

  @override
  State<YogaDetailScreen> createState() => _YogaDetailScreenState();
}

class _YogaDetailScreenState extends State<YogaDetailScreen> {
  final TextEditingController _duracionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _duracionController.text = widget.yoga.duracion.toString();
  }

  @override
  void dispose() {
    _duracionController.dispose();
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
                Image.asset(widget.yoga.imagenPath, height: 80),
                const SizedBox(height: 10),
                Text(
                  widget.yoga.nombre,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField("Tiempo:", _duracionController),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final duracion = _duracionController.text;

                if (duracion.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, completa el campo.")),
                  );
                  return;
                }

                final nuevaDuracion = int.tryParse(duracion);
                if (nuevaDuracion == null || nuevaDuracion <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Duración inválida.")),
                  );
                  return;
                }

                setState(() {
                  widget.yoga.duracion = nuevaDuracion;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Sesión iniciada por $nuevaDuracion segundos.")),
                );

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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
