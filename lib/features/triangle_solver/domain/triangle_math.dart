import 'dart:math';
import 'triangle_model.dart';

// Utility functions

double toRadians(double degrees) => degrees * pi / 180;
double toDegrees(double radians) => radians * 180 / pi;
bool _isValidAngle(double angle) => angle > 0 && angle < 180;
bool _isValidSide(double side) => side > 0;

TriangleModel solveTriangle(TriangleModel input) {
  final a = input.a;
  final b = input.b;
  final c = input.c;
  final A = input.A;
  final B = input.B;
  final C = input.C;

  // Count how many fields are filled
  final sides = [a, b, c].where((x) => x != null).length;
  final angles = [A, B, C].where((x) => x != null).length;

  if (sides + angles != 3) {
    throw Exception(
      'Exactly 3 parameters must be provided. At least one must be a side.',
    );
  }

  // SSS: three sides
  if ((a != null && b != null && c != null)) {
    return _solveSSS(a, b, c);
  }

  // SAS: two sides and the included angle
  if (a != null && b != null && C != null) {
    return _solveSAS(a, b, C);
  }
  if (a != null && c != null && B != null) {
    return _solveSAS(a, c, B);
  }
  if (b != null && c != null && A != null) {
    return _solveSAS(b, c, A);
  }

  // ASA or AAS: two angles and a side
  if (A != null && B != null && c != null) {
    return _solveASA(A, B, c, knownSide: 'c');
  }
  if (A != null && C != null && b != null) {
    return _solveASA(A, C, b, knownSide: 'b');
  }
  if (B != null && C != null && a != null) {
    return _solveASA(B, C, a, knownSide: 'a');
  }

  // SSA: two sides and a non-included angle (ambiguous case)
  if (a != null && b != null && A != null) {
    return _solveSSA(a, b, A, knownSide: 'a');
  }
  if (a != null && c != null && A != null) {
    return _solveSSA(a, c, A, knownSide: 'a');
  }
  if (b != null && a != null && B != null) {
    return _solveSSA(b, a, B, knownSide: 'b');
  }
  if (b != null && c != null && B != null) {
    return _solveSSA(b, c, B, knownSide: 'b');
  }
  if (c != null && a != null && C != null) {
    return _solveSSA(c, a, C, knownSide: 'c');
  }
  if (c != null && b != null && C != null) {
    return _solveSSA(c, b, C, knownSide: 'c');
  }

  throw Exception(
    'Unsupported or ambiguous combination. Please provide a valid set of 3 parameters (at least one side).',
  );
}

// SSS: three sides known
TriangleModel _solveSSS(double a, double b, double c) {
  if (!_isValidSide(a) || !_isValidSide(b) || !_isValidSide(c)) {
    throw Exception('All sides must be positive.');
  }
  if ((a + b <= c) || (a + c <= b) || (b + c <= a)) {
    throw Exception('The given sides do not form a valid triangle.');
  }
  final A = toDegrees(acos(_clamp((b * b + c * c - a * a) / (2 * b * c))));
  final B = toDegrees(acos(_clamp((a * a + c * c - b * b) / (2 * a * c))));
  final C = 180 - A - B;
  if (!_isValidAngle(A) || !_isValidAngle(B) || !_isValidAngle(C)) {
    throw Exception('Calculated angles are not valid.');
  }
  return TriangleModel(a: a, b: b, c: c, A: A, B: B, C: C);
}

// SAS: two sides and the included angle
TriangleModel _solveSAS(double side1, double side2, double includedAngle) {
  if (!_isValidSide(side1) ||
      !_isValidSide(side2) ||
      !_isValidAngle(includedAngle)) {
    throw Exception(
      'Sides must be positive and angle must be between 0 and 180.',
    );
  }
  final C = includedAngle;
  final c = sqrt(
    side1 * side1 + side2 * side2 - 2 * side1 * side2 * cos(toRadians(C)),
  );
  if (!_isValidSide(c)) {
    throw Exception('Calculated side is not valid.');
  }
  // Law of Sines for other angles
  double A = toDegrees(asin(_clamp((side1 * sin(toRadians(C))) / c)));
  double B = 180 - A - C;
  if (!_isValidAngle(A) || !_isValidAngle(B)) {
    throw Exception('Calculated angles are not valid.');
  }
  // Assign sides/angles to correct labels
  // side1 and side2 are adjacent to C, c is opposite C
  return TriangleModel(a: side1, b: side2, c: c, A: A, B: B, C: C);
}

// ASA/AAS: two angles and a side
TriangleModel _solveASA(
  double angle1,
  double angle2,
  double knownSideValue, {
  required String knownSide,
}) {
  if (!_isValidAngle(angle1) ||
      !_isValidAngle(angle2) ||
      !_isValidSide(knownSideValue)) {
    throw Exception('Angles must be between 0 and 180, side must be positive.');
  }
  final angle3 = 180 - angle1 - angle2;
  if (!_isValidAngle(angle3)) {
    throw Exception('Angles sum to more than or equal to 180° – not valid.');
  }
  // Assign angles and sides based on which side is known
  double A, B, C, a, b, c;
  if (knownSide == 'a') {
    A = angle1;
    B = angle2;
    C = angle3;
    a = knownSideValue;
    final factor = a / sin(toRadians(A));
    b = factor * sin(toRadians(B));
    c = factor * sin(toRadians(C));
  } else if (knownSide == 'b') {
    B = angle1;
    C = angle2;
    A = angle3;
    b = knownSideValue;
    final factor = b / sin(toRadians(B));
    a = factor * sin(toRadians(A));
    c = factor * sin(toRadians(C));
  } else if (knownSide == 'c') {
    C = angle1;
    A = angle2;
    B = angle3;
    c = knownSideValue;
    final factor = c / sin(toRadians(C));
    a = factor * sin(toRadians(A));
    b = factor * sin(toRadians(B));
  } else {
    throw Exception('Invalid known side label.');
  }
  if (!_isValidSide(a) || !_isValidSide(b) || !_isValidSide(c)) {
    throw Exception('Calculated sides are not valid.');
  }
  return TriangleModel(a: a, b: b, c: c, A: A, B: B, C: C);
}

// SSA: two sides and a non-included angle (ambiguous case)
// knownSide is the label of the side opposite the known angle
TriangleModel _solveSSA(
  double knownSideVal,
  double otherSideVal,
  double knownAngle, {
  required String knownSide,
}) {
  if (!_isValidSide(knownSideVal) ||
      !_isValidSide(otherSideVal) ||
      !_isValidAngle(knownAngle)) {
    throw Exception(
      'Sides must be positive and angle must be between 0 and 180.',
    );
  }
  // Law of Sines: sin(B)/b = sin(A)/a
  // known: a, b, A (for example)
  final A = knownAngle;
  final a = knownSideVal;
  final b = otherSideVal;
  final sinB = b * sin(toRadians(A)) / a;
  if (sinB < -1 || sinB > 1) {
    throw Exception(
      'No valid triangle can be formed with these values (SSA case).',
    );
  }
  // Two possible solutions for angle B
  final B1 = toDegrees(asin(_clamp(sinB)));
  final B2 = 180 - B1;
  // Choose the principal solution: the one with the larger angle (B2 if valid)
  double B = B2;
  if (!_isValidAngle(B) || (A + B) >= 180) {
    B = B1;
  }
  if (!_isValidAngle(B) || (A + B) >= 180) {
    throw Exception(
      'No valid triangle can be formed with these values (SSA case).',
    );
  }
  final C = 180 - A - B;
  // Law of Sines for side c
  final c = a * sin(toRadians(C)) / sin(toRadians(A));
  if (!_isValidSide(c)) {
    throw Exception('Calculated side is not valid.');
  }
  // Assign sides/angles to correct labels
  if (knownSide == 'a') {
    return TriangleModel(a: a, b: b, c: c, A: A, B: B, C: C);
  } else if (knownSide == 'b') {
    return TriangleModel(a: b, b: a, c: c, A: B, B: A, C: C);
  } else if (knownSide == 'c') {
    return TriangleModel(a: c, b: a, c: b, A: C, B: A, C: B);
  } else {
    throw Exception('Invalid known side label for SSA.');
  }
}

// Clamp value to [-1, 1] for safe asin/acos
num _clamp(num x) => x < -1 ? -1 : (x > 1 ? 1 : x);
