import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'faq_selection_screen.dart';

class FAQ_screen extends StatelessWidget {
  final List<String> preguntas = [
    '¿Cómo se hace yoga?',
    '¿Cómo se hace ejercicio?',
    '¿Cada cuánto tiempo debo ejercitarme?',
    '¿Puedo ejercitarme en casa sin equipo?',
    '¿Qué beneficios tiene el yoga?',
    '¿Qué pasa si me salto un día?',
  ];
  final Map<String, String> _respuestas = {
    '¿Cómo se hace yoga?':
        'Te pones sobre una esterilla, adoptas varias posturas suaves mientras respiras lento y profundo, mantienes la mente en la respiración y terminas relajándote unos minutos.',
    '¿Cómo se hace ejercicio?':
        'Puedes comenzar con calentamiento, luego realizar rutinas como sentadillas, flexiones y terminar con estiramientos.',
    '¿Cada cuánto tiempo debo ejercitarme?':
        'Se recomienda al menos 3 veces por semana, dependiendo de tus objetivos.',
    '¿Puedo ejercitarme en casa sin equipo?':
        'Sí, hay muchos ejercicios como planchas, sentadillas y abdominales que no requieren equipo.',
    '¿Qué beneficios tiene el yoga?':
        'Mejora la flexibilidad, reduce el estrés, fortalece los músculos y mejora la respiración.',
    '¿Qué pasa si me salto un día?':
        'No pasa nada si es ocasional. Lo importante es mantener la constancia general.',
  };
  final Map<String, String> _videos = {
    '¿Cómo se hace yoga?': 'https://youtu.be/PuBFqZuubhg',
  };
  final String numeroWhatsApp = '51991258717';
  final String mensaje = 'Hola, necesito ayuda con la app FitTrack.';
  final String numeroTelefono = '999999999';

  FAQ_screen({super.key});

  void _abrirWhatsApp() async {
    final url = Uri.parse(
        'https://wa.me/$numeroWhatsApp?text=${Uri.encodeComponent(mensaje)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('No se pudo abrir WhatsApp');
    }
  }

  void _hacerLlamada() async {
    final url = Uri.parse('tel:$numeroTelefono');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('No se pudo iniciar la llamada');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: Color(0xFFA9A8F2),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      //Preguntas
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: preguntas.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: ListTile(
                    title: Text(preguntas[index]),
                    onTap: () {
                      final preguntaSeleccionada = preguntas[index];
                      final respuesta = _respuestas[preguntaSeleccionada] ??
                          'Respuesta no disponible.';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FAQSelectionScreen(
                            pregunta: preguntaSeleccionada,
                            respuesta: respuesta,
                            videoUrl: _videos[preguntaSeleccionada],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          // Botones flotantes de wsp y para llamar
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'call',
                  backgroundColor: Color(0xFFA9A8F2),
                  onPressed: _hacerLlamada,
                  child: const Icon(Icons.call),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'whatsapp',
                  backgroundColor: Color(0xFFA9A8F2),
                  onPressed: _abrirWhatsApp,
                  child: const Icon(Icons.chat),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
