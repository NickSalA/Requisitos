// lib/utils/normalize_keypoints.dart
import 'dart:math';

List<List<double>> normalizeKeypoints(List<List<double>> keypoints) {
  final leftHip = keypoints[11];
  final rightHip = keypoints[12];
  final poseCenter = [
    (leftHip[0] + rightHip[0]) / 2.0,
    (leftHip[1] + rightHip[1]) / 2.0,
  ];

  List<List<double>> centered = keypoints
      .map((kpt) => [kpt[0] - poseCenter[0], kpt[1] - poseCenter[1]])
      .toList();

  final leftShoulder = keypoints[5];
  final rightShoulder = keypoints[6];
  final shouldersCenter = [
    (leftShoulder[0] + rightShoulder[0]) / 2.0,
    (leftShoulder[1] + rightShoulder[1]) / 2.0,
  ];
  final torsoSize = sqrt(pow(shouldersCenter[0] - poseCenter[0], 2) +
      pow(shouldersCenter[1] - poseCenter[1], 2));
  final double torsoSizeMultiplier = 2.5;
  double maxDist = 0;
  for (var kpt in centered) {
    final dist = sqrt(pow(kpt[0], 2) + pow(kpt[1], 2));
    if (dist > maxDist) maxDist = dist;
  }
  final poseSize = max(torsoSize * torsoSizeMultiplier, maxDist);

  List<List<double>> normalized =
      centered.map((kpt) => [kpt[0] / poseSize, kpt[1] / poseSize]).toList();

  return normalized;
}

List<double> getEmbedding(List<List<double>> normalizedKeypoints) {
  return normalizedKeypoints.expand((xy) => xy).toList();
}
