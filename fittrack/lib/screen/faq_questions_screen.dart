import 'package:flutter/material.dart';
import 'faq_selection_screen.dart';

class FAQQuestionsScreen extends StatelessWidget {
  final String categoria;

  FAQQuestionsScreen({super.key, required this.categoria});

  final Map<String, List<String>> _preguntasPorCategoria = {
    'Uso general': [
      '¿Qué beneficios tiene el yoga?',
      '¿Qué pasa si me salto un día?',
      '¿Es necesario practicar todos los días?',
      '¿Puedo hacer yoga si soy principiante?',
    ],
    'Posturas': [
      '¿Cómo se hace yoga?',
      '¿Qué posturas ayudan a la espalda?',
      '¿Qué postura es buena para relajarse?',
      '¿Cómo mejorar el equilibrio en yoga?',
    ],
    'Configuración': [
      '¿Cómo configuro mi perfil?',
      '¿Puedo cambiar mis datos personales?',
      '¿Cómo activo notificaciones?',
    ],
  };

  final Map<String, String> _respuestas = {
    // Uso general
    '¿Qué beneficios tiene el yoga?':
        'El yoga mejora la flexibilidad, reduce el estrés, fortalece músculos y mejora la respiración.',
    '¿Qué pasa si me salto un día?':
        'No hay problema si es ocasional. Lo importante es la regularidad a largo plazo.',
    '¿Es necesario practicar todos los días?':
        'No es obligatorio, pero la práctica regular (3-4 veces por semana) es ideal para ver beneficios.',
    '¿Puedo hacer yoga si soy principiante?':
        '¡Claro! Existen posturas suaves y adaptadas para principiantes. Lo importante es avanzar poco a poco.',

    // Posturas
    '¿Cómo se hace yoga?':
        'Busca un espacio cómodo, usa una esterilla, respira profundamente y sigue una serie de posturas según tu nivel.',
    '¿Qué posturas ayudan a la espalda?':
        'Posturas como el perro mirando abajo, la cobra y el gato-vaca son excelentes para aliviar tensión.',
    '¿Qué postura es buena para relajarse?':
        'La postura del niño (Balasana) es excelente para descansar y soltar el estrés.',
    '¿Cómo mejorar el equilibrio en yoga?':
        'Practica posturas como el árbol o el guerrero III, y enfoca tu mirada en un punto fijo (drishti).',

    // Configuración
    '¿Cómo configuro mi perfil?':
        'Ve al menú principal > Perfil. Desde ahí puedes ingresar tu nombre, edad y preferencias.',
    '¿Puedo cambiar mis datos personales?':
        'Sí, desde la sección de perfil puedes editar tus datos en cualquier momento.',
    '¿Cómo activo notificaciones?':
        'Ve a Ajustes > Notificaciones y habilita los recordatorios para sesiones y consejos.',
  };

  final Map<String, String> _videos = {
    '¿Cómo se hace yoga?': 'https://youtu.be/PuBFqZuubhg',
    '¿Qué posturas ayudan a la espalda?': 'https://youtu.be/wFWEpZf1NFk',
    '¿Qué postura es buena para relajarse?': 'https://youtu.be/v7AYKMP6rOE',
    '¿Cómo mejorar el equilibrio en yoga?': 'https://youtu.be/x7B7bXT9IhU',
  };

  @override
  Widget build(BuildContext context) {
    final preguntas = _preguntasPorCategoria[categoria] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(categoria),
        backgroundColor: const Color(0xFFA9A8F2),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: preguntas.length,
        padding: const EdgeInsets.only(bottom: 100),
        itemBuilder: (context, index) {
          final pregunta = preguntas[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: ListTile(
                title: Text(pregunta),
                onTap: () {
                  final respuesta =
                      _respuestas[pregunta] ?? 'Respuesta no disponible.';
                  final videoUrl = _videos[pregunta];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FAQSelectionScreen(
                        pregunta: pregunta,
                        respuesta: respuesta,
                        videoUrl: videoUrl,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
