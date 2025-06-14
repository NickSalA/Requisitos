import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQ_screen extends StatelessWidget {
  final List<String> preguntas = [
    '¿Cómo se hace yoga?',
    '¿Cómo se hace ejercicio?',
    '¿Cada cuánto tiempo debo ejercitarme?',
    '¿Puedo ejercitarme en casa sin equipo?',
    '¿Qué beneficios tiene el yoga?',
    '¿Qué pasa si me salto un día?',
  ];

  final String numeroWhatsApp = '51991258717'; 
  final String mensaje = 'Hola, necesito ayuda con la app FitTrack.';
  final String numeroTelefono = '999999999'; 

  void _abrirWhatsApp() async {
    final url = Uri.parse('https://wa.me/$numeroWhatsApp?text=${Uri.encodeComponent(mensaje)}');
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: ListTile(
                    title: Text(preguntas[index]),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Seleccionaste: ${preguntas[index]}')),
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
