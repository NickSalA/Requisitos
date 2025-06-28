import 'dart:math';
import 'package:flutter/material.dart';

double dist(List<double> a, List<double> b) =>
    sqrt(pow(a[0] - b[0], 2) + pow(a[1] - b[1], 2));

double angle3Pts(List<double> a, List<double> b, List<double> c) {
  // ∠ABC  (b es vértice)
  final ab = [a[0] - b[0], a[1] - b[1]];
  final cb = [c[0] - b[0], c[1] - b[1]];
  final dot = ab[0] * cb[0] + ab[1] * cb[1];
  final mag =
      sqrt(ab[0] * ab[0] + ab[1] * ab[1]) * sqrt(cb[0] * cb[0] + cb[1] * cb[1]);
  return acos(dot / mag) * 180 / pi;
}

/// Imprime solo si activas [debug] al llamar
void logMetric(String name, num value, {bool debug = false}) {
  if (debug) debugPrint('$name: ${value.toStringAsFixed(2)}');
}

double angle(List<double> A, List<double> B, List<double> C) {
  final ABx = A[0] - B[0];
  final ABy = A[1] - B[1];
  final CBx = C[0] - B[0];
  final CBy = C[1] - B[1];

  final dot = ABx * CBx + ABy * CBy;
  final mag = sqrt(ABx * ABx + ABy * ABy) * sqrt(CBx * CBx + CBy * CBy) + 1e-5;
  return acos(max(-1, min(1, dot / mag))); // clamp por seguridad numérica
}
