import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/usuario.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nombre = '';

  @override
  void initState() {
    super.initState();
    _loadUsuario();
  }

  Future<void> _loadUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('usuario');
    if (jsonString != null) {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      final usuario = Usuario.fromJson(map);
      setState(() => _nombre = usuario.nombre);
    }
  }

  void _onButtonTap(String nombreBoton) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Has presionado $nombreBoton')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 220,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFA9A8F2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo y avatar alineados en fila
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/icons/logo.png', width: 40, height: 40),
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 30, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Textos debajo del logo
                Text('¡Bienvenido!',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.white,
                    )),
                Text(
                  _nombre,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text('¿Listo para moverte hoy?',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Botones más grandes usando Expanded y menor childAspectRatio
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.9, // Más alto
                children: [
                  _buildCard("Ejercicio", "assets/icons/ejerciciosHome.png"),
                  _buildCard("Yoga", "assets/icons/yogaHome.png"),
                  _buildCard("FAQ", "assets/icons/faqHome.png"),
                  _buildCard("Historial", "assets/icons/historialHome.png"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String titulo, String imagePath) {
    return GestureDetector(
      onTap: () => _onButtonTap(titulo),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 60),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
