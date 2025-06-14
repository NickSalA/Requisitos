import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screen/splash_decider.dart';
import 'modelView/yoga_provider.dart';
import 'modelView/sesion_yoga_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => YogaSessionViewModel()),
    ChangeNotifierProvider(create: (_) => PoseSessionViewModel()),
  ], child: const FitTrackApp()));
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
