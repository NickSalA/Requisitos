import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/splash_decider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      home: const SplashDecider(), // Aquí arranca el flujo de decisión
    );
  }
}
