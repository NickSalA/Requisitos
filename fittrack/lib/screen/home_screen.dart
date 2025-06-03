import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/usuario.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla principal que se muestra después del onboarding/splash minimal.
/// Ejemplo sencillo que lee el nombre del usuario de SharedPreferences.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, $_nombre', style: GoogleFonts.montserrat()),
        backgroundColor: const Color(0xFFA9A8F2),
      ),
      body: Center(
        child: Text(
          'Esta es la pantalla principal.\nTu nombre: $_nombre',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}
