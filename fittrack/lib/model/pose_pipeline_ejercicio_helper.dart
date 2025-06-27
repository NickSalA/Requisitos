import 'package:fittrack/modelView/ejercicio_session_view_model.dart';
import 'package:fittrack/utils/normalize_keypoints.dart';

class PosePipelineEjercicioHelper {
  final EjercicioSessionViewModel viewModel;

  PosePipelineEjercicioHelper(this.viewModel);

  void process(List<List<double>> keypoints) {
    final normalized = normalizeKeypoints(keypoints);
    viewModel.actualizarKeypoints(normalized); // Para visualización en pantalla

    // Obtener puntos clave de ambos lados
    final hipL = normalized[11];    // left_hip
    final kneeL = normalized[13];   // left_knee
    final shoulderL = normalized[5]; // left_shoulder

    final hipR = normalized[12];    // right_hip
    final kneeR = normalized[14];   // right_knee
    final shoulderR = normalized[6]; // right_shoulder

    // Validar que no haya puntos faltantes
    final puntos = [hipL, kneeL, shoulderL, hipR, kneeR, shoulderR];
    if (puntos.any((kp) => kp.length < 2 || kp[0] == 0 || kp[1] == 0)) {
      viewModel.actualizarFeedback("Puntos no detectados");
      return;
    }

    // Promediar coordenadas Y de ambos lados para mayor estabilidad
    final hipY = (hipL[1] + hipR[1]) / 2;
    final kneeY = (kneeL[1] + kneeR[1]) / 2;
    final shoulderY = (shoulderL[1] + shoulderR[1]) / 2;

    // Umbrales de detección
    final bool isDown = hipY > kneeY + 0.03;
    final bool isUpright = shoulderY < hipY - 0.05;

    if (isDown && isUpright) {
      if (!viewModel.estabaAbajo) {
        viewModel.estabaAbajo = true;
      }
    }

    // Detectar repetición al subir
    if (viewModel.estabaAbajo && hipY < kneeY - 0.02) {
      viewModel.incrementarRepeticion(posturaCorrecta: true);
      viewModel.estabaAbajo = false;
    } else if (!isUpright) {
      viewModel.actualizarFeedback("Mantén la espalda recta");
    }
  }

  void dispose() {
    // Por ahora no hay recursos que cerrar
  }
}
