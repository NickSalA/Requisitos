import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQSelectionScreen extends StatelessWidget {
  final String pregunta;
  final String respuesta;
  final String? videoUrl;

  const FAQSelectionScreen({
    super.key,
    required this.pregunta,
    required this.respuesta,
    this.videoUrl,
  });

  void _contactarPorWhatsApp() async {
    final whatsappUrl = Uri.parse(
        'https://wa.me/51994405280?text=Hola%2C%20necesito%20ayuda%20con%20la%20app%20FitTrack.');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir WhatsApp');
    }
  }

  void _hacerLlamada() async {
    final telUrl = Uri.parse('tel:+51994405280');
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    } else {
      debugPrint('No se pudo hacer la llamada');
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Pregunta y respuesta
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 246, 245, 245),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 7,
                                offset: Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Centra verticalmente
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centra horizontalmente
                          children: [
                            Text(
                              pregunta,
                              style: GoogleFonts.montserrat(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign:
                                  TextAlign.center, // Centra el texto también
                            ),
                            const SizedBox(height: 12),
                            Text(
                              respuesta,
                              style: GoogleFonts.poppins(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            if (videoUrl != null) ...[
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  final Uri url = Uri.parse(videoUrl!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'No se pudo abrir el video')),
                                    );
                                  }
                                },
                                child: Text(
                                  'Video de referencia:\n$videoUrl',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ),

          // Botones flotantes (llamada y whatsapp)
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'call',
                  backgroundColor: Color(0xFFA9A8F2),
                  onPressed: _hacerLlamada,
                  child: const Icon(Icons.phone, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'whatsapp',
                  backgroundColor: Color(0xFFA9A8F2),
                  onPressed: _contactarPorWhatsApp,
                  child: const Icon(Icons.chat, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
