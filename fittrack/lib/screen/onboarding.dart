import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modelView/onboarding.dart';
import '../screen/home_screen.dart';

// ignore: unused_element
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 169, 168, 242),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Image.asset(
                  'assets/icons/logo.png',
                  height: 32,
                )),
            const SizedBox(width: 20),
            Text(
              'FitTrack',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 32), // Margen bajo el AppBar
              Image.asset('assets/icons/inicioImage.png', height: 197),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Entrena desde casa con precisión',
                    style: GoogleFonts.montserrat(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Remodela tu cuerpo. Vive siempre en forma. Un estilo de vida saludable.',
                    style: GoogleFonts.montserrat(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Ingrese su nombre:',
                    style: GoogleFonts.montserrat(fontSize: 14)),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (text) => vm.nombre = text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  errorText: vm.error,
                ),
              ),
              const Spacer(),
              vm.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA9A8F2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final ok = await vm.submit();
                          if (ok) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => const HomeScreen()));
                          }
                        },
                        child: Text('¡Empieza ahora!',
                            style: GoogleFonts.montserrat(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
