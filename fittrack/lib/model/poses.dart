import 'dart:math';

import 'package:flutter/material.dart';

// Mapea índices de los keypoints de MoveNet
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

// Distancia euclídea
double dist(List<double> a, List<double> b) =>
    sqrt(pow(a[0] - b[0], 2) + pow(a[1] - b[1], 2));

bool isTreePose(List<List<double>> kpts) {
  final rightAnkle = kpts[Keypoint.rightAnkle.index];
  final leftKnee = kpts[Keypoint.leftKnee.index];
  final leftAnkle = kpts[Keypoint.leftAnkle.index];
  final rightKnee = kpts[Keypoint.rightKnee.index];
  final leftWrist = kpts[Keypoint.leftWrist.index];
  final rightWrist = kpts[Keypoint.rightWrist.index];
  final nose = kpts[Keypoint.nose.index];
  final leftShoulder = kpts[Keypoint.leftShoulder.index];
  final rightShoulder = kpts[Keypoint.rightShoulder.index];

  bool pieSobrePierna = (((rightAnkle[0] - leftKnee[0]).abs() < 0.1 &&
          rightAnkle[1] < leftKnee[1]) ||
      ((leftAnkle[0] - rightKnee[0]).abs() < 0.1 &&
          leftAnkle[1] < rightKnee[1]));

  bool ambasManosArriba = (leftWrist[1] < nose[1]) && (rightWrist[1] < nose[1]);
  bool manosAlPechoReal = ((leftWrist[1] - leftShoulder[1]).abs() < 0.1 &&
      (rightWrist[1] - rightShoulder[1]).abs() < 0.1);

  // --- DEBUG ---
  debugPrint('pieSobrePierna: $pieSobrePierna');
  debugPrint('ambasManosArriba: $ambasManosArriba');
  debugPrint('manosAlPechoReal: $manosAlPechoReal');

  if (!pieSobrePierna) {
    debugPrint('❌ Pie no está correctamente apoyado en la pierna contraria');
  }
  if (!(ambasManosArriba || manosAlPechoReal)) {
    debugPrint('❌ Ni ambas manos arriba ni ambas al pecho');
  }

  return pieSobrePierna && (ambasManosArriba || manosAlPechoReal);
}

bool isWarriorPose(List<List<double>> kpts) {
  final leftShoulder = kpts[Keypoint.leftShoulder.index];
  final rightShoulder = kpts[Keypoint.rightShoulder.index];
  final leftElbow = kpts[Keypoint.leftElbow.index];
  final rightElbow = kpts[Keypoint.rightElbow.index];
  final leftKnee = kpts[Keypoint.leftKnee.index];
  final rightKnee = kpts[Keypoint.rightKnee.index];
  final leftHip = kpts[Keypoint.leftHip.index];
  final rightHip = kpts[Keypoint.rightHip.index];
  final leftAnkle = kpts[Keypoint.leftAnkle.index];
  final rightAnkle = kpts[Keypoint.rightAnkle.index];

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

bool isCobraPose(List<List<double>> kpts) {
  final leftHip = kpts[Keypoint.leftHip.index];
  final rightHip = kpts[Keypoint.rightHip.index];
  final leftShoulder = kpts[Keypoint.leftShoulder.index];
  final rightShoulder = kpts[Keypoint.rightShoulder.index];
  final leftWrist = kpts[Keypoint.leftWrist.index];
  final rightWrist = kpts[Keypoint.rightWrist.index];

  // Menos exigente con la diferencia hombros-caderas
  final alturaShouldersVsHips = ((leftShoulder[1] + rightShoulder[1]) / 2.0) -
      ((leftHip[1] + rightHip[1]) / 2.0);
  final manosCercaCaderas =
      (dist(leftWrist, leftHip) < 0.23) && (dist(rightWrist, rightHip) < 0.23);

  return alturaShouldersVsHips < -0.12 && manosCercaCaderas;
}

bool isDogPose(List<List<double>> kpts) {
  final leftHip = kpts[Keypoint.leftHip.index];
  final rightHip = kpts[Keypoint.rightHip.index];
  final leftWrist = kpts[Keypoint.leftWrist.index];
  final rightWrist = kpts[Keypoint.rightWrist.index];
  final leftAnkle = kpts[Keypoint.leftAnkle.index];
  final rightAnkle = kpts[Keypoint.rightAnkle.index];

  // Más flexible: caderas solo un poco arriba de muñecas y tobillos
  final avgHipY = (leftHip[1] + rightHip[1]) / 2.0;
  final avgWristY = (leftWrist[1] + rightWrist[1]) / 2.0;
  final avgAnkleY = (leftAnkle[1] + rightAnkle[1]) / 2.0;

  final caderasArriba =
      avgHipY < avgWristY - 0.04 && avgHipY < avgAnkleY - 0.04;
  return caderasArriba;
}

// no_pose, igual menos restrictivo
bool isNoPose(List<List<double>> kpts) {
  final leftHip = kpts[Keypoint.leftHip.index];
  final rightHip = kpts[Keypoint.rightHip.index];
  final leftShoulder = kpts[Keypoint.leftShoulder.index];
  final rightShoulder = kpts[Keypoint.rightShoulder.index];
  final leftWrist = kpts[Keypoint.leftWrist.index];
  final rightWrist = kpts[Keypoint.rightWrist.index];
  final leftAnkle = kpts[Keypoint.leftAnkle.index];
  final rightAnkle = kpts[Keypoint.rightAnkle.index];

  // Solo chequea que la persona esté más o menos recta y brazos abajo
  final alineacionPiernas = ((leftHip[0] - leftAnkle[0]).abs() < 0.15) &&
      ((rightHip[0] - rightAnkle[0]).abs() < 0.15);
  final hombrosCaderasAlineados =
      ((leftShoulder[0] - leftHip[0]).abs() < 0.20) &&
          ((rightShoulder[0] - rightHip[0]).abs() < 0.20);
  final brazosAbajo = leftWrist[1] > leftHip[1] && rightWrist[1] > rightHip[1];

  return alineacionPiernas && hombrosCaderasAlineados && brazosAbajo;
}

bool isPoseSelectedCorrect(List<List<double>> kpts, String selectedPose) {
  switch (selectedPose.toLowerCase()) {
    case 'tree':
      return isTreePose(kpts);
    case 'warrior':
      return isWarriorPose(kpts);
    case 'cobra':
      return isCobraPose(kpts);
    case 'dog':
      return isDogPose(kpts);
    default:
      return false;
  }
}

String getTreeFeedback(List<List<double>> kpts) {
  final leftAnkle = kpts[Keypoint.leftAnkle.index];
  final rightKnee = kpts[Keypoint.rightKnee.index];
  final rightAnkle = kpts[Keypoint.rightAnkle.index];
  final leftKnee = kpts[Keypoint.leftKnee.index];
  final leftWrist = kpts[Keypoint.leftWrist.index];
  final rightWrist = kpts[Keypoint.rightWrist.index];
  final nose = kpts[Keypoint.nose.index];

  if ((rightAnkle[0] - leftKnee[0]).abs() > 0.15 &&
      (leftAnkle[0] - rightKnee[0]).abs() > 0.15) {
    return "Asegúrate de apoyar el pie sobre la pierna contraria.";
  }
  if (leftWrist[1] > nose[1] && rightWrist[1] > nose[1]) {
    return "¡Prueba a subir los brazos para mayor dificultad!";
  }
  return "¡Excelente Árbol! Mantén el equilibrio y respira profundo.";
}

String getWarriorFeedback(List<List<double>> kpts) {
  final leftShoulder = kpts[Keypoint.leftShoulder.index];
  final rightShoulder = kpts[Keypoint.rightShoulder.index];
  final leftWrist = kpts[Keypoint.leftWrist.index];
  final rightWrist = kpts[Keypoint.rightWrist.index];
  final leftKnee = kpts[Keypoint.leftKnee.index];
  final leftHip = kpts[Keypoint.leftHip.index];

  if ((leftWrist[1] - leftShoulder[1]).abs() > 0.12 ||
      (rightWrist[1] - rightShoulder[1]).abs() > 0.12) {
    return "Brazos deben estar alineados y rectos.";
  }
  if ((leftKnee[1] - leftHip[1]) < 0.07) {
    return "Flexiona más la pierna delantera.";
  }
  return "¡Perfecto Guerrero! Mantén la fuerza en las piernas.";
}

String getFeedback(String poseClass, List<List<double>> kpts) {
  switch (poseClass) {
    case 'tree':
      return getTreeFeedback(kpts);
    case 'warrior':
      return getWarriorFeedback(kpts);
    case 'cobra':
      return '¡Excelente Cobra!';
    case 'dog':
      return '¡Buen Down Dog!';
    case 'no_pose':
      return 'Relájate y prepárate para la próxima postura.';
    default:
      return 'No se reconoce la postura. Ajusta tu alineación.';
  }
}
