import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'faq_questions_screen.dart';

class FAQScreen extends StatelessWidget {
  final List<String> categorias = [
    'Uso general',
    'Posturas',
    'Configuración',
  ];

  final String numeroWhatsApp = '51991258717';
  final String mensaje = 'Hola, necesito ayuda con la app FitTrack.';
  final String numeroTelefono = '51991258717';

  FAQScreen({super.key});

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ - Seccion de preguntas'),
        backgroundColor: const Color(0xFFA9A8F2),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              return _buildCategoriaCard(context, categorias[index]);
            },
          ),
          _buildFloatingButtons()
        ],
      ),
    );
  }

  Widget _buildCategoriaCard(BuildContext context, String categoria) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: ListTile(
          title: Text(categoria),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FAQQuestionsScreen(categoria: categoria),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'call',
            backgroundColor: const Color(0xFFA9A8F2),
            onPressed: _hacerLlamada,
            child: const Icon(Icons.call),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'whatsapp',
            backgroundColor: const Color(0xFFA9A8F2),
            onPressed: _abrirWhatsApp,
            child: const Icon(Icons.chat),
          ),
        ],
      ),
    );
  }
}
