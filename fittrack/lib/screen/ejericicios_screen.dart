import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/ejercicio.dart';

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
          height: 220,
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
        
        // Contenido principal
        Column(
          children: [
            // Espacio para AppBar
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
            
            // Encabezado
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                ],
              ),
            ),

            // Contenido de ejercicios
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // GridView 2x2 para los ejercicios
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2, // 2 columnas
                        mainAxisSpacing: 15, // Espacio vertical entre items
                        crossAxisSpacing: 15, // Espacio horizontal entre items
                        childAspectRatio: 1.0, // Relación ancho/alto (cuadrados)
                        physics: const NeverScrollableScrollPhysics(), // Deshabilita scroll
                        children: _ejercicios.map((ejercicio) {
                          return _buildExerciseCard(ejercicio);
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
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
                    const SizedBox(height:27),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
// Asegúrate que tu _buildExerciseCard tenga un tamaño adecuado para el GridView
Widget _buildExerciseCard(Ejercicio ejercicio) {
return ElevatedButton(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccionaste: ${ejercicio.nombre}')),
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
        const SizedBox(height: 5),
      ],
    ),
  );
}
}
