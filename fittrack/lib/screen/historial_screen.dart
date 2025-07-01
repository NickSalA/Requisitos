import 'package:fittrack/screen/historial_sesiones_screen.dart';
import 'package:fittrack/screen/historial_yoga.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'nombre': 'goddess',
        'imagen': 'assets/icons/goddess.png',
        'tipo': 'yoga'
      },
      {
        'nombre': 'warrior',
        'imagen': 'assets/icons/guerrero.png',
        'tipo': 'yoga'
      },
      {'nombre': 'tree', 'imagen': 'assets/icons/arbol.png', 'tipo': 'yoga'},
      {'nombre': 'chair', 'imagen': 'assets/icons/chair.png', 'tipo': 'yoga'},
      {
        'nombre': 'Raices y equilibrio',
        'imagen': 'assets/icons/sesion_1.png',
        'tipo': 'sesion'
      },
      {
        'nombre': 'Giros y Detox',
        'imagen': 'assets/icons/sesion_2.png',
        'tipo': 'sesion'
      },
      {
        'nombre': 'Fortalece y libera',
        'imagen': 'assets/icons/sesion_3.png',
        'tipo': 'sesion'
      },
      {
        'nombre': 'Fuerza en la pared',
        'imagen': 'assets/icons/sesion_4.png',
        'tipo': 'sesion'
      },
      {'nombre': 'Próximamente', 'imagen': null, 'tipo': 'none'},
    ];

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
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildTitle(),
                  const SizedBox(height: 50),
                  _buildEntrenamientoGrid(items, context),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Text(
                'Historial',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      );

  Widget _buildPurpleHeader() => Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 160,
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

  Widget _buildEntrenamientoGrid(
      List<Map<String, dynamic>> items, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.24;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 15,
          childAspectRatio: 0.82,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildEntrenamientoButton(items[index], buttonSize, context);
        },
      ),
    );
  }

  Widget _buildEntrenamientoButton(
      Map<String, dynamic> item, double size, BuildContext context) {
    final bool isYoga = item['tipo'] == 'yoga';
    final bool isSesion = item['tipo'] == 'sesion';
    final bool isComingSoon = item['imagen'] == null;

    return InkWell(
      onTap: isComingSoon
          ? null
          : () {
              if (isYoga) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HistorialYogaScreen(exerciseName: item['nombre']),
                  ),
                );
              } else if (isSesion) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HistorialSesionesScreen(sessionName: item['nombre']),
                  ),
                );
              }
            },
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isComingSoon ? Colors.grey[200] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(isComingSoon ? 0.1 : 0.3),
                  spreadRadius: isComingSoon ? 0 : 2,
                  blurRadius: isComingSoon ? 0 : 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: item['imagen'] != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      item['imagen'],
                      fit: BoxFit.contain,
                    ),
                  )
                : const Icon(Icons.lock_outline, size: 35, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              item['nombre'],
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.1,
                color: isComingSoon ? Colors.grey : Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
