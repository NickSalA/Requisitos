import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/modo_cronometro.dart';
import 'seleccion_cronometro.dart';
import 'package:provider/provider.dart';
import '../modelView/cronometro_provider.dart';
import 'cronometro_detalles.dart';

class CronometroScreen extends StatefulWidget {
  const CronometroScreen({super.key});

  @override
  State<CronometroScreen> createState() => _CronometroScreenState();
}

class _CronometroScreenState extends State<CronometroScreen> {
  final List<ModoCronometro> _cronometro = [
    ModoCronometro(
      id: 1,
      nombre: 'Raices y equilibrio ',
      descripcion:
          'Secuencia de 4 posturas suaves que te enraízan, relajan la zona lumbar y cultivan el equilibrio. Ideal para principiantes o como pausa activa para volver al centro en solo 15 minutos.',
      imagenPath: 'assets/icons/sesion_1.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Principiantes',
      duracion: 15, // Duración en segundos
      posesPath: [
        'assets/icons/sesion_1_1.png',
        'assets/icons/sesion_1_2.png',
        'assets/icons/sesion_1_3.png',
        'assets/icons/sesion_1_4.png',
      ],
    ),
    ModoCronometro(
      id: 2,
      nombre: 'Giros y Detox',
      descripcion:
          'Secuencia dinámica de cuatro torsiones profundas—estocada creciente girada, guerrero girado, perro boca abajo con torsión y triángulo caído—que masajean los órganos internos, liberan la espalda y fortalecen core y piernas. Ideal para intermedios que buscan desintoxicar y recargar energía en solo 15 minutos.',
      imagenPath: 'assets/icons/sesion_2.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Intermedio',
      duracion: 30, // Duración en segundos
      posesPath: [
        'assets/icons/sesion_2_1.png',
        'assets/icons/sesion_2_2.png',
        'assets/icons/sesion_2_3.png',
        'assets/icons/sesion_2_4.png',
      ],
    ),
    ModoCronometro(
      id: 3,
      nombre: 'Fortalece y libera',
      descripcion:
          'Cuatro posturas que combinan apertura de isquiotibiales y caderas, trabajo intenso de core y un suave masaje digestivo para cerrar. Perfecta para activar todo el cuerpo y soltar tensión lumbar en apenas 15 minutos.',
      imagenPath: 'assets/icons/sesion_3.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Intermedio',
      duracion: 20, // Duración en segundos
      posesPath: [
        'assets/icons/sesion_3_1.png',
        'assets/icons/sesion_3_2.png',
        'assets/icons/sesion_3_3.png',
        'assets/icons/sesion_3_4.png',
      ],
    ),
    ModoCronometro(
      id: 4,
      nombre: 'Fuerza en la pared',
      descripcion:
          'Secuencia progresiva de cuatro posturas con apoyo en la pared—silla, silla a una pierna, bote y handstand en tuck—que esculpen glúteos y core, refuerzan hombros y enseñan la alineación necesaria para las inversiones. Ideal para practicantes avanzados que quieren potenciar estabilidad y confianza en solo 15 minutos.',
      imagenPath: 'assets/icons/sesion_4.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Avanzado',
      duracion: 25, // Duración en segundos
      posesPath: [
        'assets/icons/sesion_4_1.png',
        'assets/icons/sesion_4_2.png',
        'assets/icons/sesion_4_3.png',
        'assets/icons/sesion_4_4.png',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selected =
        context.watch<CronoometroSessionViewModel>().selectedCronometro;

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
          _buildPurpleHeader(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildTitle(),
                  const SizedBox(height: 10),
                  _buildGrid(context),
                  const SizedBox(height: 20),
                  _buildStartButton(context, selected),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurpleHeader() => Positioned(
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
      );

  Widget _buildTitle() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Image.asset('assets/icons/logo.png', width: 50, height: 50),
            const SizedBox(height: 15),
            Text(
              'Encuentra tu paz interior',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );

  Widget _buildGrid(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.0,
          children: _cronometro.map((pose) {
            return _buildYogaPoseCard(context, pose);
          }).toList(),
        ),
      );

  Widget _buildYogaPoseCard(BuildContext context, ModoCronometro pose) {
    final isSelected =
        context.watch<CronoometroSessionViewModel>().selectedCronometro?.id ==
            pose.id;

    return ElevatedButton(
      onPressed: () {
        context.read<CronoometroSessionViewModel>().selectPose(pose);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CronometroDetailScreen(cronometro: pose),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFD6D4F4) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        padding: const EdgeInsets.all(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(pose.imagenPath, width: 75, height: 75),
          const SizedBox(height: 10),
          Text(
            pose.nombre,
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

  Widget _buildStartButton(BuildContext context, ModoCronometro? selected) =>
      SizedBox(
        width: 340,
        child: ElevatedButton(
          onPressed: selected != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SeleccionCronometroScreen(),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA9A8F2),
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            '¡Comenzar sesión!',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
}
