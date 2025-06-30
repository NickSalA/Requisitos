import 'modo_cronometro.dart';

extension NombrePoseHelper on ModoCronometro {
  /// Devuelve un nombre legible para la pose en `index`
  /// a partir del nombre del asset.
  String nombrePose(int index) {
    if (index < 0 || index >= posesPath.length) return '';

    final file = posesPath[index] // p. ej. sesion_1_3.png
        .split('/')
        .last
        .replaceAll('.png', ''); // sesion_1_3
    return file
        .replaceAll('_', ' ') // sesion 1 3
        .replaceFirst(RegExp(r'^\d+\s*'), '') // quita dígitos iniciales
        .trim();
  }
}
