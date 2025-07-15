import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/solver_controller.dart';
import '../domain/triangle_model.dart';
import 'dart:math';

class TriangleCanvas extends ConsumerWidget {
  const TriangleCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final triangleState = ref.watch(triangleProvider);

    return CustomPaint(
      painter: _TrianglePainter(triangleState.value),
      size: Size.infinite,
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final TriangleModel? triangle;

  _TrianglePainter(this.triangle);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint background grid
    final gridPaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    const spacing = 20.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (triangle == null || !triangle!.isFullySolved) return;

    final trianglePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Normalize side lengths to fit the screen (fit both width and height)
    final double a = triangle!.a!;
    final double b = triangle!.b!;
    final double c = triangle!.c!;
    final double A = triangle!.A!;
    final double B = triangle!.B!;
    final double C = triangle!.C!;

    // Law of Cosines layout: p1 at (0,0), p2 at (c,0), p3 at (b*cos(C), -b*sin(C))
    final Offset rawP1 = Offset(0, 0);
    final Offset rawP2 = Offset(c, 0);
    final double angleC = toRadians(C);
    final Offset rawP3 = Offset(b * cos(angleC), -b * sin(angleC));

    // Find bounding box
    final points = [rawP1, rawP2, rawP3];
    final minX = points.map((p) => p.dx).reduce(min);
    final maxX = points.map((p) => p.dx).reduce(max);
    final minY = points.map((p) => p.dy).reduce(min);
    final maxY = points.map((p) => p.dy).reduce(max);
    final triangleWidth = maxX - minX;
    final triangleHeight = maxY - minY;

    // Compute scale to fit both width and height, with margin
    const marginRatio = 0.1; // 10% margin
    final double availableWidth = size.width * (1 - 2 * marginRatio);
    final double availableHeight = size.height * (1 - 2 * marginRatio);
    final double scale = min(
      availableWidth / triangleWidth,
      availableHeight / triangleHeight,
    );

    // Center the triangle
    final double offsetX =
        (size.width - triangleWidth * scale) / 2 - minX * scale;
    final double offsetY =
        (size.height - triangleHeight * scale) / 2 - minY * scale;

    // Transform points
    final p1 = Offset(rawP1.dx * scale + offsetX, rawP1.dy * scale + offsetY);
    final p2 = Offset(rawP2.dx * scale + offsetX, rawP2.dy * scale + offsetY);
    final p3 = Offset(rawP3.dx * scale + offsetX, rawP3.dy * scale + offsetY);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    canvas.drawPath(path, trianglePaint);

    // --- Labeling sides and angles ---
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
      backgroundColor: Colors.white.withOpacity(0.7),
    );
    final textPainter = (String text) => TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Sides: a (BC), b (CA), c (AB)
    // Points: p1 (A), p2 (B), p3 (C)
    // Side a is opposite A, between p2 and p3
    // Side b is opposite B, between p1 and p3
    // Side c is opposite C, between p1 and p2

    // Label side a
    final midA = Offset((p2.dx + p3.dx) / 2, (p2.dy + p3.dy) / 2);
    final labelA = 'a = ${a.toStringAsFixed(2)}';
    final tpA = textPainter(labelA)..layout();
    tpA.paint(canvas, midA - Offset(tpA.width / 2, tpA.height / 2));

    // Label side b
    final midB = Offset((p1.dx + p3.dx) / 2, (p1.dy + p3.dy) / 2);
    final labelB = 'b = ${b.toStringAsFixed(2)}';
    final tpB = textPainter(labelB)..layout();
    tpB.paint(canvas, midB - Offset(tpB.width / 2, tpB.height / 2));

    // Label side c
    final midC = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    final labelC = 'c = ${c.toStringAsFixed(2)}';
    final tpC = textPainter(labelC)..layout();
    tpC.paint(canvas, midC - Offset(tpC.width / 2, tpC.height / 2));

    // Angles: A at p1, B at p2, C at p3
    // Offset angle labels slightly away from the vertex for readability
    Offset angleOffset(
      Offset vertex,
      Offset adj1,
      Offset adj2,
      double distance,
    ) {
      final dir = ((adj1 + adj2) / 2 - vertex).direction;
      return vertex + Offset(distance * cos(dir), distance * sin(dir));
    }

    const angleLabelDist = 28.0;

    // Label angle A
    final posA = angleOffset(p1, p2, p3, angleLabelDist);
    final labelAngleA = 'A = ${A.toStringAsFixed(1)}°';
    final tpAngleA = textPainter(labelAngleA)..layout();
    tpAngleA.paint(
      canvas,
      posA - Offset(tpAngleA.width / 2, tpAngleA.height / 2),
    );

    // Label angle B
    final posB = angleOffset(p2, p1, p3, angleLabelDist);
    final labelAngleB = 'B = ${B.toStringAsFixed(1)}°';
    final tpAngleB = textPainter(labelAngleB)..layout();
    tpAngleB.paint(
      canvas,
      posB - Offset(tpAngleB.width / 2, tpAngleB.height / 2),
    );

    // Label angle C
    final posC = angleOffset(p3, p1, p2, angleLabelDist);
    final labelAngleC = 'C = ${C.toStringAsFixed(1)}°';
    final tpAngleC = textPainter(labelAngleC)..layout();
    tpAngleC.paint(
      canvas,
      posC - Offset(tpAngleC.width / 2, tpAngleC.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  double toRadians(double degrees) => degrees * pi / 180;
}
