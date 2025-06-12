import 'package:fittrack/screen/yoga_detalles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/yoga.dart';
import 'package:provider/provider.dart';
import 'package:fittrack/screen/seleccion_yoga.dart';
import '../modelView/yoga_provider.dart';

class YogaScreen extends StatefulWidget {
  const YogaScreen({super.key});

  @override
  State<YogaScreen> createState() => _YogaScreenState();
}

class _YogaScreenState extends State<YogaScreen> {
  final List<Yoga> _posesYoga = [
    Yoga(
      id: 1,
      nombre: 'Cobra',
      descripcion: 'Mejora el equilibrio y la concentración',
      imagenPath: 'assets/icons/cobra.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Equilibrio',
      duracion: 30,
    ),
    Yoga(
      id: 2,
      nombre: 'Tree',
      descripcion: 'Estira la columna y fortalece brazos y piernas',
      imagenPath: 'assets/icons/arbol.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Flexibilidad',
      duracion: 45,
    ),
    Yoga(
      id: 3,
      nombre: 'Warrior2',
      descripcion: 'Fortalece piernas y mejora la resistencia',
      imagenPath: 'assets/icons/guerrero.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Fuerza',
      duracion: 40,
    ),
    Yoga(
      id: 4,
      nombre: 'Downdog',
      descripcion: 'Ideal para meditación y relajación',
      imagenPath: 'assets/icons/downdog.png',
      fechaCreacion: DateTime.now(),
      tipo: 'Relajación',
      duracion: 60,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<YogaSessionViewModel>().selectedPose;

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
          children: _posesYoga.map((pose) {
            return _buildYogaPoseCard(context, pose);
          }).toList(),
        ),
      );

  Widget _buildYogaPoseCard(BuildContext context, Yoga pose) {
    final isSelected =
        context.watch<YogaSessionViewModel>().selectedPose?.id == pose.id;

    return ElevatedButton(
      onPressed: () {
        context.read<YogaSessionViewModel>().selectPose(pose);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => YogaDetailScreen(yoga: pose),
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

  Widget _buildStartButton(BuildContext context, Yoga? selected) => SizedBox(
        width: 340,
        child: ElevatedButton(
          onPressed: selected != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SeleccionYogaScreen(),
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
