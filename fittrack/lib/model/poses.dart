import 'dart:collection';

import 'package:fittrack/utils/pose_math.dart';

/// Índices que entrega MoveNet
enum Keypoint {
  nose,
  leftEye,
  rightEye,
  leftEar,
  rightEar,
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
}

final _ankleOK = SmoothBool();
final _kneesOK = SmoothBool();
final _elbowsOK = SmoothBool();
final _wristsOK = SmoothBool();

const tolY = 192 * 0.10; // 10 % alto
const tolXPx = 192 * 0.05; // 5 % ancho
// -----------------------------------------------------------------------------
// Funciones de postura – todas aceptan [debug] opcional para imprimir métricas.
// -----------------------------------------------------------------------------
bool ok(List<double> p, [double minScore = .45]) {
  // Si vienes de xyKeypoints (sin score) => ok siempre
  if (p.length < 3) return true;
  return p[2] >= minScore;
}

bool isTreePose(List<List<double>> k, {bool debug = false}) {
  final rk = k[Keypoint.rightKnee.index];
  final lk = k[Keypoint.leftKnee.index];
  final ra = k[Keypoint.rightAnkle.index];
  final la = k[Keypoint.leftAnkle.index];
  final rw = k[Keypoint.rightWrist.index];
  final lw = k[Keypoint.leftWrist.index];
  final ls = k[Keypoint.leftShoulder.index];
  final rs = k[Keypoint.rightShoulder.index];
  final nose = k[Keypoint.nose.index];

  final pieSobrePierna = ((ra[0] - lk[0]).abs() < tolXPx && ra[1] < lk[1]) ||
      ((la[0] - rk[0]).abs() < tolXPx && la[1] < rk[1]);

  final manosArriba = rw[1] < nose[1] && lw[1] < nose[1];

  final manosPecho = (rw[1] < rs[1] + tolY) && (lw[1] < ls[1] + tolY);

  logMetric('pie_sobre_pierna', pieSobrePierna ? 1 : 0, debug: debug);
  logMetric('manos_arriba', manosArriba ? 1 : 0, debug: debug);
  logMetric('manos_pecho', manosPecho ? 1 : 0, debug: debug);

  return pieSobrePierna && (manosArriba ^ manosPecho);
}

bool isWarriorPose(List<List<double>> k, {bool debug = false}) {
  final leftShoulder = k[Keypoint.leftShoulder.index];
  final rightShoulder = k[Keypoint.rightShoulder.index];
  final leftElbow = k[Keypoint.leftElbow.index];
  final rightElbow = k[Keypoint.rightElbow.index];
  final leftKnee = k[Keypoint.leftKnee.index];
  final rightKnee = k[Keypoint.rightKnee.index];
  final leftHip = k[Keypoint.leftHip.index];
  final rightHip = k[Keypoint.rightHip.index];
  final leftAnkle = k[Keypoint.leftAnkle.index];
  final rightAnkle = k[Keypoint.rightAnkle.index];

  // 1. Brazos alineados (hombro-codo)
  final yMediaShoulders = (leftShoulder[1] + rightShoulder[1]) / 2;
  final yMediaElbows = (leftElbow[1] + rightElbow[1]) / 2;
  final alineacionBrazos = (yMediaElbows - yMediaShoulders).abs() < 0.3;

  // 2. Brazos extendidos: hombro-codo horizontal más permisivo
  final brazoIzqExtendido = (leftShoulder[0] - leftElbow[0]).abs() > 0.02;
  final brazoDerExtendido = (rightShoulder[0] - rightElbow[0]).abs() > 0.02;

  // 3. Al menos una rodilla flexionada (más laxa)
  final rodillaIzqFlex = (leftKnee[1] - leftHip[1]) < -0.03;
  final rodillaDerFlex = (rightKnee[1] - rightHip[1]) < -0.03;

  // 4. Piernas separadas (más permisivo para espacio en casa)
  final separacionTobillos = (leftAnkle[0] - rightAnkle[0]).abs() > 0.05;

  return alineacionBrazos &&
      brazoIzqExtendido &&
      brazoDerExtendido &&
      (rodillaIzqFlex || rodillaDerFlex) &&
      separacionTobillos;
}

bool isGoddessPose(List<List<double>> k, {bool debug = false}) {
  // ─── 0. Puntos ----------------------------------------------------------------
  final aL = k[Keypoint.leftAnkle.index];
  final aR = k[Keypoint.rightAnkle.index];
  final kL = k[Keypoint.leftKnee.index];
  final kR = k[Keypoint.rightKnee.index];
  final hL = k[Keypoint.leftHip.index];
  final hR = k[Keypoint.rightHip.index];
  final sL = k[Keypoint.leftShoulder.index];
  final sR = k[Keypoint.rightShoulder.index];
  final eL = k[Keypoint.leftElbow.index];
  final eR = k[Keypoint.rightElbow.index];
  final wL = k[Keypoint.leftWrist.index];
  final wR = k[Keypoint.rightWrist.index];

  // ─── 1. Piernas anchas ---------------------------------------------------------
  final hipW = (hL[0] - hR[0]).abs();
  final anklesWideNow = (aL[0] - aR[0]).abs() > hipW * 1.25;
  final anklesWide = _ankleOK.add(anklesWideNow);

  // ─── 2. Rodillas ≈ 90 ° (ángulo) ----------------------------------------------
  final angL = angle3Pts(hL, kL, aL); // 70–110 °
  final angR = angle3Pts(hR, kR, aR);
  final kneesBentNow =
      (angL > 55 && angL < 140) && (angR > 55 && angR < 140); // 55-140°
  final kneesBent = _kneesOK.add(kneesBentNow);

  // ─── 3. Codos a la altura de hombros ------------------------------------------
  final elbowLvlNow =
      (eL[1] - sL[1]).abs() < 0.15 && (eR[1] - sR[1]).abs() < 0.15;
  final elbowsLvl = _elbowsOK.add(elbowLvlNow);

  // ─── 4. Muñecas ligeramente por encima de codos --------------------------------
  const tolW = 0.04;
  final wristsUpNow = wL[1] < eL[1] + tolW && wR[1] < eR[1] + tolW;
  final wristsUp = _wristsOK.add(wristsUpNow);

  // ─── 5. Debug ------------------------------------------------------------------
  if (debug) {
    // imprime la métrica “cruda” (sin suavizar) y la suavizada
    void log(String name, bool now, bool smoothed) =>
        print('$name: ${now ? 1 : 0}  ->  ${smoothed ? 1 : 0}');
    log('anklesWide', anklesWideNow, anklesWide);
    log('kneesBent', kneesBentNow, kneesBent);
    log('elbowsLvl', elbowLvlNow, elbowsLvl);
    log('wristsUp', wristsUpNow, wristsUp);
  }

  // ─── 6. Decisión ---------------------------------------------------------------
  final okParts = [anklesWide, kneesBent, elbowsLvl, wristsUp].where((v) => v);
  return okParts.length >= 2; // al menos 3 de 4
}

// ─────────────────────────────────────────────────────────────
// 2. CHAIR  (Utkatasana)
// ─────────────────────────────────────────────────────────────
bool isChairPose(List<List<double>> k, {bool debug = false}) {
  final lAnkle = k[Keypoint.leftAnkle.index];
  final rAnkle = k[Keypoint.rightAnkle.index];
  final lKnee = k[Keypoint.leftKnee.index];
  final rKnee = k[Keypoint.rightKnee.index];
  final lHip = k[Keypoint.leftHip.index];
  final rHip = k[Keypoint.rightHip.index];
  final lShoulder = k[Keypoint.leftShoulder.index];
  final rShoulder = k[Keypoint.rightShoulder.index];
  final lElbow = k[Keypoint.leftElbow.index];
  final rElbow = k[Keypoint.rightElbow.index];
  final lWrist = k[Keypoint.leftWrist.index];
  final rWrist = k[Keypoint.rightWrist.index];

  // ➊ Pies casi juntos
  final feetTogether = (lAnkle[0] - rAnkle[0]).abs() < 0.3;

  // ➋ Rodillas por delante de las caderas (flexión ≥ ≈90°)
  final kneesBent = (lHip[1] - lKnee[1]) > 0.10 && (rHip[1] - rKnee[1]) > 0.1;
  // ➌ Brazos estirados por encima de la cabeza (línea hombro-muñeca)
  final armsUp = lWrist[1] < lShoulder[1] - 0.1 &&
      rWrist[1] < rShoulder[1] - 0.1 &&
      // codos casi rectos
      (lElbow[1] - lWrist[1]).abs() < 0.05 &&
      (rElbow[1] - rWrist[1]).abs() < 0.05;

  // ➍ Inclinación del tronco : hombros algo delante de caderas
  final torsoForward =
      lShoulder[0] > lHip[0] + 0.1 && rShoulder[0] > rHip[0] + 0.1;

  logMetric('feetTogether', feetTogether ? 1 : 0, debug: debug);
  logMetric('kneesBent', kneesBent ? 1 : 0, debug: debug);
  logMetric('armsUp', armsUp ? 1 : 0, debug: debug);
  logMetric('torsoFwd', torsoForward ? 1 : 0, debug: debug);
  final okparts = [
    feetTogether,
    kneesBent,
    armsUp,
    torsoForward,
  ].where((v) => v);
  return okparts.length >= 2; // al menos 3 de 4
}

// Postura base "sin pose" (de pie, brazos abajo)
bool isNoPose(List<List<double>> k, {bool debug = false}) {
  final alineacionPiernas =
      ((k[Keypoint.leftHip.index][0] - k[Keypoint.leftAnkle.index][0]).abs() <
              0.15) &&
          ((k[Keypoint.rightHip.index][0] - k[Keypoint.rightAnkle.index][0])
                  .abs() <
              0.15);
  final hombrosAlineados =
      ((k[Keypoint.leftShoulder.index][0] - k[Keypoint.leftHip.index][0])
                  .abs() <
              0.20) &&
          ((k[Keypoint.rightShoulder.index][0] - k[Keypoint.rightHip.index][0])
                  .abs() <
              0.20);
  final brazosAbajo =
      k[Keypoint.leftWrist.index][1] > k[Keypoint.leftHip.index][1] &&
          k[Keypoint.rightWrist.index][1] > k[Keypoint.rightHip.index][1];

  logMetric('piernas_rectas', alineacionPiernas ? 1 : 0, debug: debug);
  logMetric('hombros_rectos', hombrosAlineados ? 1 : 0, debug: debug);
  logMetric('brazos_abajo', brazosAbajo ? 1 : 0, debug: debug);

  return alineacionPiernas && hombrosAlineados && brazosAbajo;
}

// -----------------------------------------------------------------------------
// Orquestador: determina si la postura elegida es correcta
// -----------------------------------------------------------------------------

bool isPoseSelectedCorrect(List<List<double>> k, String selectedPose,
    {bool debug = false}) {
  switch (selectedPose.toLowerCase()) {
    case 'tree':
      return isTreePose(k, debug: debug);
    case 'warrior':
      return isWarriorPose(k, debug: debug);
    case 'goddess':
      return isGoddessPose(k, debug: debug);
    case 'chair':
      return isChairPose(k, debug: debug);
    default:
      return isNoPose(k, debug: debug);
  }
}

// -----------------------------------------------------------------------------
// Feedback (sin cambios de fondo, pero podrías usar métricas para personalizar)
// -----------------------------------------------------------------------------

String getTreeFeedback(List<List<double>> k) {
  final leftAnkle = k[Keypoint.leftAnkle.index];
  final rightKnee = k[Keypoint.rightKnee.index];
  final rightAnkle = k[Keypoint.rightAnkle.index];
  final leftKnee = k[Keypoint.leftKnee.index];
  final leftWrist = k[Keypoint.leftWrist.index];
  final rightWrist = k[Keypoint.rightWrist.index];
  final nose = k[Keypoint.nose.index];

  if ((rightAnkle[0] - leftKnee[0]).abs() > 0.15 &&
      (leftAnkle[0] - rightKnee[0]).abs() > 0.15) {
    return 'Asegura el pie sobre la pierna contraria.';
  }
  if (leftWrist[1] > nose[1] && rightWrist[1] > nose[1]) {
    return 'Prueba a subir los brazos para mayor reto.';
  }
  return '¡Buen Árbol! Mantén el equilibrio y respira.';
}

String getWarriorFeedback(List<List<double>> k) {
  final angRodilla = angle3Pts(k[Keypoint.leftHip.index],
      k[Keypoint.leftKnee.index], k[Keypoint.leftAnkle.index]);

  if ((90 - angRodilla).abs() > 15) {
    final falta = (angRodilla - 90).round();
    return 'Flexiona la rodilla $falta° más.';
  }
  return '¡Excelente Guerrero! Mantén la fuerza.';
}

String getFeedback(String poseClass, List<List<double>> k) {
  switch (poseClass) {
    case 'tree':
      return getTreeFeedback(k);
    case 'warrior':
      return getWarriorFeedback(k);
    case 'goddess':
      return '¡Excelente Goddess!';
    case 'chair':
      return '¡Buen Chair!';
    default:
      return 'Relájate y prepárate para la siguiente postura.';
  }
}

class SmoothBool {
  final int _win;
  final _q = Queue<bool>();
  SmoothBool([this._win = 5]);

  bool add(bool v) {
    _q.addLast(v);
    if (_q.length > _win) _q.removeFirst();
    // “verdadero” si TODOS los valores recientes son true
    return _q.every((e) => e);
  }
}
