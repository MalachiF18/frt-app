import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/target_spec.dart';
import '../../models/weapon_spec.dart';

class RangePainter extends CustomPainter {
  const RangePainter({
    required this.hits,
    this.targetType = TargetType.bullseye,
    this.targetDistance = TargetDistance.yd7,
  });

  final List<HitMark> hits;
  final TargetType targetType;
  final TargetDistance targetDistance;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Brick Wall Background
    final wall = Paint()..color = const Color(0xFF55504A);
    canvas.drawRect(Offset.zero & size, wall);

    final mortar = Paint()
      ..color = const Color(0xFF35322F)
      ..strokeWidth = 2;

    for (var y = 0.0; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), mortar);
      final shift = ((y / 42).round().isEven) ? 0.0 : 40.0;
      for (var x = shift; x < size.width; x += 80) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 42), mortar);
      }
    }

    // 2. Target Dimensions with Distance Scaling
    final scale = targetDistance.scaleFactor;
    final baseWidth = math.min(190.0, size.width * .48);
    final targetWidth = baseWidth * scale;
    final targetHeight = targetWidth * 1.28;

    final targetCenter = Offset(
      size.width / 2,
      (targetHeight / 2 + 28) * (0.8 + 0.2 * scale),
    );

    final target = Rect.fromCenter(
      center: targetCenter,
      width: targetWidth,
      height: targetHeight,
    );

    // Target Shadow
    canvas.drawShadow(
      Path()..addRect(target),
      Colors.black,
      12 * scale,
      true,
    );

    // Render Target Type
    switch (targetType) {
      case TargetType.bullseye:
        _drawBullseyeTarget(canvas, target);
        break;
      case TargetType.steelGong:
        _drawSteelTarget(canvas, target);
        break;
      case TargetType.silhouette:
        _drawSilhouetteTarget(canvas, target);
        break;
    }

    // 3. Draw Hits
    for (final hit in hits) {
      final point = Offset(
        target.left + hit.offset.dx * target.width,
        target.top + hit.offset.dy * target.height,
      );

      final hitColor = hit.score == 10
          ? const Color(0xFFFFD700)
          : (hit.score > 0 ? Colors.black : const Color(0xFF8B0000));

      canvas.drawCircle(point, 4 * scale, Paint()..color = hitColor);
      canvas.drawCircle(
        point,
        7 * scale,
        Paint()
          ..color = const Color(0xFF202020)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawBullseyeTarget(Canvas canvas, Rect target) {
    canvas.drawRect(
      target,
      Paint()..color = const Color(0xFFF0E5C7),
    );

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF202020);

    final ringStep = target.width * 0.08;
    for (var radius = target.width * .1;
        radius < target.width * .42;
        radius += ringStep) {
      canvas.drawCircle(target.center, radius, ring);
    }

    // Bullseye Center (10 Ring)
    canvas.drawCircle(
      target.center,
      target.width * 0.05,
      Paint()..color = const Color(0xFFD32F2F),
    );
  }

  void _drawSteelTarget(Canvas canvas, Rect target) {
    // Steel Plate Background
    final steelPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF8A95A5),
          const Color(0xFF4A5565),
          const Color(0xFF2A3545),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(target);

    canvas.drawOval(target, steelPaint);

    // Steel Border / Edge Highlight
    canvas.drawOval(
      target,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFFB0C0D0),
    );

    // Center Target Sticker
    canvas.drawCircle(
      target.center,
      target.width * 0.18,
      Paint()..color = const Color(0xFFFF5722),
    );
  }

  void _drawSilhouetteTarget(Canvas canvas, Rect target) {
    // Cardboard Background
    canvas.drawRect(
      target,
      Paint()..color = const Color(0xFFC2B280),
    );

    // Silhouette Outline Path
    final path = Path();
    final center = target.center;
    final w = target.width;
    final h = target.height;

    // Head
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx, target.top + h * 0.22),
      width: w * 0.35,
      height: h * 0.25,
    ));

    // Torso
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, target.top + h * 0.58),
        width: w * 0.72,
        height: h * 0.52,
      ),
      const Radius.circular(12),
    ));

    canvas.drawPath(path, Paint()..color = const Color(0xFF1E242B));

    // Scoring Zones (A-Zone Center Mass & Head)
    final zonePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF4A5565);

    canvas.drawCircle(
      Offset(center.dx, target.top + h * 0.22),
      w * 0.1,
      zonePaint,
    );

    canvas.drawCircle(
      Offset(center.dx, target.top + h * 0.52),
      w * 0.2,
      zonePaint,
    );
  }

  @override
  bool shouldRepaint(covariant RangePainter oldDelegate) {
    return oldDelegate.hits.length != hits.length ||
        oldDelegate.targetType != targetType ||
        oldDelegate.targetDistance != targetDistance;
  }
}
