import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_minimal.dart';
import 'onboarding.dart';
import 'package:provider/provider.dart';
import '../repository/usuario_repositorio.dart';
import '../modelView/onboarding.dart';

/// Este widget decide en `initState` si el usuario ya completó el onboarding.
///  • Si `seenOnboarding == false` → va directo a OnboardingScreen.
///  • Si `seenOnboarding == true`  → muestra un SplashMinimal rápido y luego HomeScreen.
class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!mounted) return;

    if (seenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashMinimal()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => OnboardingViewModel(UsuarioRepository()),
            child: const OnboardingScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se decide, devolvemos un Container vacío para no mostrar nada.
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
