import 'dart:math';

// Keypoint enum (igual que en tu código)
enum Keypoint {
  nose, //0
  leftEye, //1
  rightEye, //2
  leftEar, //3
  rightEar, //4
  leftShoulder, //5
  rightShoulder, //6
  leftElbow, //7
  rightElbow, //8
  leftWrist, //9
  rightWrist, //10
  leftHip, //11
  rightHip, //12
  leftKnee, //13
  rightKnee, //14
  leftAnkle, //15
  rightAnkle, //16
}

List<List<double>> keypointsXY(List<List<double>> keypointsWithScore) =>
    keypointsWithScore.map((kpt) => [kpt[0], kpt[1]]).toList();

List<List<double>> normalizeKeypoints(List<List<double>> keypoints) {
  final leftHip = keypoints[Keypoint.leftHip.index];
  final rightHip = keypoints[Keypoint.rightHip.index];
  final poseCenter = [
    (leftHip[0] + rightHip[0]) / 2.0,
    (leftHip[1] + rightHip[1]) / 2.0,
  ];

  List<List<double>> centered = keypoints
      .map((kpt) => [kpt[0] - poseCenter[0], kpt[1] - poseCenter[1]])
      .toList();

  final leftShoulder = keypoints[Keypoint.leftShoulder.index];
  final rightShoulder = keypoints[Keypoint.rightShoulder.index];
  final shouldersCenter = [
    (leftShoulder[0] + rightShoulder[0]) / 2.0,
    (leftShoulder[1] + rightShoulder[1]) / 2.0,
  ];
  final torsoSize = sqrt(pow(shouldersCenter[0] - poseCenter[0], 2) +
      pow(shouldersCenter[1] - poseCenter[1], 2));

  double maxDist = 0.0;
  for (final kpt in centered) {
    final dist = sqrt(pow(kpt[0], 2) + pow(kpt[1], 2));
    if (dist > maxDist) maxDist = dist;
  }
  final poseSize = max(torsoSize * 2.5, maxDist);

  return centered.map((kpt) => [kpt[0] / poseSize, kpt[1] / poseSize]).toList();
}

List<double> getEmbedding(List<List<double>> normalizedKeypoints) =>
    normalizedKeypoints.expand((xy) => xy).toList();
