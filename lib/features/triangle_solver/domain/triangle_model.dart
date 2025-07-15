class TriangleModel {
  final double? a; // Side a
  final double? b; // Side b
  final double? c; // Side c

  final double? A; // Angle A in degrees (opposite side a)
  final double? B; // Angle B in degrees (opposite side b)
  final double? C; // Angle C in degrees (opposite side c)

  final Map<String, bool>
  userEntered; // Tracks if a field was entered by user (true) or auto-generated (false)

  const TriangleModel({
    this.a,
    this.b,
    this.c,
    this.A,
    this.B,
    this.C,
    Map<String, bool>? userEntered,
  }) : userEntered = userEntered ?? const {};

  bool get hasEnoughInfo {
    final sides = [a, b, c].where((x) => x != null).length;
    final angles = [A, B, C].where((x) => x != null).length;
    return (sides + angles) == 3;
  }

  bool get isFullySolved {
    return [a, b, c, A, B, C].every((x) => x != null);
  }

  Map<String, double> toMap() {
    return {
      if (a != null) 'a': a!,
      if (b != null) 'b': b!,
      if (c != null) 'c': c!,
      if (A != null) 'A': A!,
      if (B != null) 'B': B!,
      if (C != null) 'C': C!,
    };
  }

  TriangleModel copyWith({
    double? a,
    double? b,
    double? c,
    double? A,
    double? B,
    double? C,
    Map<String, bool>? userEntered,
  }) {
    return TriangleModel(
      a: a ?? this.a,
      b: b ?? this.b,
      c: c ?? this.c,
      A: A ?? this.A,
      B: B ?? this.B,
      C: C ?? this.C,
      userEntered: userEntered ?? Map<String, bool>.from(this.userEntered),
    );
  }

  @override
  String toString() {
    return 'Sides: a=a, b=b, c=c | Angles: A=A°, B=B°, C=C° | User: $userEntered';
  }
}
