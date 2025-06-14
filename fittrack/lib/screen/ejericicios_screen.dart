import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/ejercicio.dart';
import 'ejercicios_detalles.dart'; 
class EjerciciosScreen extends StatefulWidget {
  const EjerciciosScreen({super.key});

  @override
  State<EjerciciosScreen> createState() => _EjerciciosScreenState();
}

class _EjerciciosScreenState extends State<EjerciciosScreen> {
  final List<Ejercicio> _ejercicios = [
    Ejercicio(
      id: 1,
      nombre: 'Sentadilla',
      descripcion: 'Ejercicio para piernas y glúteos',
      imagenPath: 'assets/icons/sentadillas.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Fuerza',
      series: 3,
      repeticiones: 12,
      descanso: 30,
    ),
    Ejercicio(
      id: 2,
      nombre: 'Planchas',
      descripcion: 'Ejercicio para core y abdomen',
      imagenPath: 'assets/icons/planchas.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Resistencia',
      series: 3,
      repeticiones: 1,
      descanso: 30,
    ),
    Ejercicio(
      id: 3,
      nombre: 'Curl de bíceps',
      descripcion: 'Ejercicio para brazos',
      imagenPath: 'assets/icons/curl de biceps.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Fuerza',
      series: 3,
      repeticiones: 10,
      descanso: 30,
    ),
    Ejercicio(
      id: 4,
      nombre: 'Laterales hombros',
      descripcion: 'Ejercicio para hombros',
      imagenPath: 'assets/icons/laterales hombros.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Fuerza',
      series: 3,
      repeticiones: 12,
      descanso: 30,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Fondo morado superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFA9A8F2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
          ),

          // Contenido principal con scroll
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Encabezado
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Image.asset('assets/icons/logo.png', width: 50, height: 50),
                        const SizedBox(height: 15),
                        Text(
                          'Establece tu reto de hoy!',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Contenido con Grid y botón
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), // Evita scroll anidado
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 1.0,
                          children: _ejercicios.map((ejercicio) {
                            return _buildExerciseCard(context, ejercicio);
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 340,
                          child: ElevatedButton(
                            onPressed: () {
                              // Lógica para iniciar los ejercicios
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA9A8F2),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              '¡Iniciar!',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildExerciseCard(BuildContext context, Ejercicio ejercicio) {
    return ElevatedButton(
      onPressed: () {
        // Navegar a la nueva pantalla de detalles
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EjercicioDetailScreen(ejercicio: ejercicio),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        padding: const EdgeInsets.all(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ejercicio.imagenPath, width: 75, height: 75),
          const SizedBox(height: 10),
          Text(
            ejercicio.nombre,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
