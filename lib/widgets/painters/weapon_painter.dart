import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/weapon_spec.dart';

class WeaponPainter extends CustomPainter {
  const WeaponPainter({
    required this.weapon,
    this.firing = false,
    this.shot = 0,
    this.reloading = false,
    this.reloadProgress = 0,
  });

  final WeaponSpec weapon;
  final bool firing;
  final int shot;

  final bool reloading;
  final double reloadProgress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(
      size.width / 360,
      size.height / 160,
    );

    switch (weapon.type) {
      case WeaponType.glock19x:
        _drawGlock(
          canvas,
          slideColor: const Color(0xFFC89553),
          frameColor: const Color(0xFFAA733A),
        );

        if (firing) {
          _drawFlash(
            canvas,
            Offset(
              301,
              shot.isEven ? 58 : 61,
            ),
            scale: .95,
          );

          _drawCasing(
            canvas,
            const Offset(225, 40),
          );
        }

        break;

      case WeaponType.glock17:
        _drawGlock(
          canvas,
          slideColor: const Color(0xFF22272B),
          frameColor: const Color(0xFF121416),
        );

        if (firing) {
          _drawFlash(
            canvas,
            Offset(
              301,
              shot.isEven ? 58 : 61,
            ),
            scale: .95,
          );

          _drawCasing(
            canvas,
            const Offset(225, 40),
          );
        }

        break;

      case WeaponType.riflePistol:
        _drawArPistol(canvas);

        if (firing) {
          _drawFlash(
            canvas,
            Offset(
              328,
              shot.isEven ? 68 : 70,
            ),
            scale: 1.08,
          );

          _drawCasing(
            canvas,
            const Offset(203, 50),
          );
        }

        break;

      case WeaponType.dp12:
        _drawDp12(canvas);

        if (firing) {
          _drawFlash(
            canvas,
            Offset(
              334,
              shot.isOdd ? 79 : 66,
            ),
            scale: 1.2,
          );
        }

        break;
    }

    canvas.restore();
  }

  double _dropAmount(double maxDrop) {
    if (!reloading) {
      return 0;
    }

    final p = reloadProgress;

    if (p < .38) {
      return maxDrop * (p / .38);
    }

    if (p < .62) {
      return maxDrop;
    }

    return maxDrop * (1 - ((p - .62) / .38));
  }

  double _pumpOffset() {
    if (!reloading) {
      return 0;
    }

    final p = reloadProgress;

    if (p < .45) {
      return -30 * (p / .45);
    }

    return -30 * (1 - ((p - .45) / .55));
  }

  void _drawGlock(
    Canvas canvas, {
    required Color slideColor,
    required Color frameColor,
  }) {
    final black = Paint()..color = const Color(0xFF0B0C0D);
    final slide = Paint()..color = slideColor;
    final frame = Paint()..color = frameColor;

    final outline = Paint()
      ..color = Colors.black.withOpacity(.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final detail = Paint()
      ..color = Colors.black.withOpacity(.35)
      ..strokeWidth = 2;

    final slideShape = RRect.fromRectAndRadius(
      const Rect.fromLTWH(65, 42, 222, 34),
      const Radius.circular(4),
    );

    canvas.drawRRect(slideShape, slide);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(73, 38, 196, 7),
        const Radius.circular(2),
      ),
      slide,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(281, 49, 20, 20),
        const Radius.circular(3),
      ),
      black,
    );

    canvas.drawOval(
      const Rect.fromLTWH(288, 54, 9, 10),
      Paint()..color = const Color(0xFF363A3D),
    );

    canvas.drawRect(
      const Rect.fromLTWH(78, 34, 12, 8),
      black,
    );

    canvas.drawRect(
      const Rect.fromLTWH(259, 34, 8, 8),
      black,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(210, 49, 34, 13),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.black.withOpacity(.28),
    );

    for (double x = 78; x <= 108; x += 7) {
      canvas.drawLine(
        Offset(x, 48),
        Offset(x - 3, 70),
        Paint()
          ..color = Colors.black.withOpacity(.4)
          ..strokeWidth = 2.5,
      );
    }

    final lowerFrame = Path()
      ..moveTo(88, 76)
      ..lineTo(267, 76)
      ..lineTo(260, 89)
      ..lineTo(225, 89)
      ..lineTo(217, 96)
      ..lineTo(183, 96)
      ..lineTo(175, 103)
      ..lineTo(139, 103)
      ..lineTo(118, 92)
      ..lineTo(91, 89)
      ..close();

    canvas.drawPath(lowerFrame, frame);

    final triggerGuard = Path()
      ..moveTo(174, 81)
      ..quadraticBezierTo(207, 79, 221, 91)
      ..quadraticBezierTo(216, 112, 183, 114)
      ..quadraticBezierTo(163, 112, 159, 99);

    canvas.drawPath(
      triggerGuard,
      Paint()
        ..color = const Color(0xFF0B0C0D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final trigger = Path()
      ..moveTo(190, 88)
      ..quadraticBezierTo(187, 102, 198, 108);

    canvas.drawPath(
      trigger,
      Paint()
        ..color = const Color(0xFF0B0C0D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final grip = Path()
      ..moveTo(118, 88)
      ..lineTo(168, 88)
      ..lineTo(177, 101)
      ..lineTo(166, 148)
      ..lineTo(118, 146)
      ..lineTo(105, 106)
      ..close();

    canvas.drawPath(grip, frame);

    canvas.drawLine(
      const Offset(119, 94),
      const Offset(123, 141),
      detail,
    );

    for (double y = 103; y <= 135; y += 8) {
      canvas.drawLine(
        Offset(124, y),
        Offset(161, y + 3),
        Paint()
          ..color = Colors.black.withOpacity(.22)
          ..strokeWidth = 2,
      );
    }

    for (double y = 106; y <= 134; y += 9) {
      for (double x = 128; x <= 157; x += 9) {
        canvas.drawCircle(
          Offset(x, y),
          1.2,
          Paint()..color = Colors.black.withOpacity(.25),
        );
      }
    }

    final magazineDrop = _dropAmount(35);

    canvas.save();
    canvas.translate(0, magazineDrop);

    final magazine = RRect.fromRectAndRadius(
      const Rect.fromLTWH(122, 125, 43, 25),
      const Radius.circular(2),
    );

    canvas.drawRRect(
      magazine,
      Paint()..color = frameColor.withOpacity(.9),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(114, 143, 57, 8),
        const Radius.circular(2),
      ),
      black,
    );

    canvas.restore();

    canvas.drawLine(
      const Offset(222, 82),
      const Offset(258, 82),
      detail,
    );

    for (double x = 228; x <= 252; x += 8) {
      canvas.drawLine(
        Offset(x, 82),
        Offset(x, 87),
        detail,
      );
    }

    canvas.drawRRect(slideShape, outline);
    canvas.drawPath(lowerFrame, outline);
    canvas.drawPath(grip, outline);
  }

  void _drawArPistol(Canvas canvas) {
    final body = Paint()..color = const Color(0xFF292D31);
    final darker = Paint()..color = const Color(0xFF151719);
    final accent = Paint()..color = weapon.accent;

    final outline = Paint()
      ..color = Colors.black.withOpacity(.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final brace = Path()
      ..moveTo(33, 66)
      ..lineTo(65, 55)
      ..lineTo(95, 57)
      ..lineTo(84, 70)
      ..lineTo(101, 81)
      ..lineTo(89, 96)
      ..lineTo(63, 94)
      ..lineTo(37, 84)
      ..close();

    canvas.drawPath(brace, darker);

    canvas.drawRect(
      const Rect.fromLTWH(82, 65, 38, 8),
      darker,
    );

    final receiver = RRect.fromRectAndRadius(
      const Rect.fromLTWH(112, 56, 96, 29),
      const Radius.circular(4),
    );

    canvas.drawRRect(receiver, body);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(205, 58, 73, 23),
        const Radius.circular(3),
      ),
      body,
    );

    canvas.drawRect(
      const Rect.fromLTWH(277, 65, 46, 8),
      darker,
    );

    canvas.drawRect(
      const Rect.fromLTWH(320, 61, 10, 16),
      accent,
    );

    canvas.drawRect(
      const Rect.fromLTWH(118, 49, 158, 6),
      darker,
    );

    for (double x = 125; x < 267; x += 13) {
      canvas.drawRect(
        Rect.fromLTWH(x, 46, 6, 4),
        accent,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(152, 34, 28, 17),
        const Radius.circular(4),
      ),
      accent,
    );

    canvas.drawRect(
      const Rect.fromLTWH(160, 29, 12, 7),
      darker,
    );

    final magazineDrop = _dropAmount(48);

    canvas.save();
    canvas.translate(0, magazineDrop);
    canvas.rotate(
      reloading ? .12 * math.sin(math.pi * reloadProgress) : 0,
    );

    final magazine = Path()
      ..moveTo(162, 84)
      ..lineTo(193, 84)
      ..lineTo(190, 101)
      ..lineTo(182, 124)
      ..lineTo(151, 116)
      ..lineTo(154, 97)
      ..close();

    canvas.drawPath(magazine, darker);

    canvas.drawLine(
      const Offset(160, 93),
      const Offset(185, 99),
      Paint()
        ..color = weapon.accent.withOpacity(.7)
        ..strokeWidth = 3,
    );

    canvas.drawPath(magazine, outline);
    canvas.restore();

    final grip = Path()
      ..moveTo(129, 83)
      ..lineTo(153, 83)
      ..lineTo(148, 128)
      ..lineTo(124, 122)
      ..close();

    canvas.drawPath(grip, accent);

    final forwardGrip = Path()
      ..moveTo(225, 80)
      ..lineTo(243, 80)
      ..lineTo(240, 108)
      ..lineTo(224, 107)
      ..close();

    canvas.drawPath(forwardGrip, accent);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(174, 62, 27, 11),
        const Radius.circular(2),
      ),
      darker,
    );

    canvas.drawCircle(
      const Offset(145, 72),
      4,
      accent,
    );

    canvas.drawPath(brace, outline);
    canvas.drawRRect(receiver, outline);
    canvas.drawPath(grip, outline);
  }

  void _drawDp12(Canvas canvas) {
    final body = Paint()..color = const Color(0xFF151719);
    final dark = Paint()..color = const Color(0xFF262A2E);
    final accent = Paint()..color = weapon.accent;

    final outline = Paint()
      ..color = Colors.black.withOpacity(.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final stock = Path()
      ..moveTo(26, 70)
      ..lineTo(66, 54)
      ..lineTo(100, 58)
      ..lineTo(92, 75)
      ..lineTo(102, 87)
      ..lineTo(89, 102)
      ..lineTo(55, 98)
      ..lineTo(29, 88)
      ..close();

    canvas.drawPath(stock, dark);

    final receiver = RRect.fromRectAndRadius(
      const Rect.fromLTWH(92, 55, 121, 38),
      const Radius.circular(9),
    );

    canvas.drawRRect(receiver, body);

    canvas.drawRect(
      const Rect.fromLTWH(111, 48, 98, 6),
      dark,
    );

    for (double x = 119; x <= 197; x += 13) {
      canvas.drawRect(
        Rect.fromLTWH(x, 45, 7, 4),
        accent,
      );
    }

    final pumpMovement = _pumpOffset();

    canvas.save();
    canvas.translate(pumpMovement, 0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(187, 58, 55, 30),
        const Radius.circular(5),
      ),
      accent,
    );

    for (double x = 194; x <= 231; x += 9) {
      canvas.drawLine(
        Offset(x, 62),
        Offset(x, 84),
        Paint()
          ..color = Colors.black.withOpacity(.28)
          ..strokeWidth = 2,
      );
    }

    canvas.restore();

    canvas.drawRect(
      const Rect.fromLTWH(241, 63, 88, 8),
      dark,
    );

    canvas.drawRect(
      const Rect.fromLTWH(241, 77, 88, 8),
      dark,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(327, 61, 9, 12),
        const Radius.circular(2),
      ),
      body,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(327, 75, 9, 12),
        const Radius.circular(2),
      ),
      body,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(118, 62, 42, 13),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withOpacity(.09),
    );

    final grip = Path()
      ..moveTo(155, 90)
      ..lineTo(185, 90)
      ..lineTo(177, 134)
      ..lineTo(150, 129)
      ..close();

    canvas.drawPath(grip, dark);

    canvas.drawOval(
      const Rect.fromLTWH(168, 80, 39, 27),
      Paint()
        ..color = const Color(0xFF08090A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawLine(
      const Offset(187, 88),
      const Offset(184, 101),
      Paint()
        ..color = const Color(0xFF08090A)
        ..strokeWidth = 3,
    );

    canvas.drawPath(stock, outline);
    canvas.drawRRect(receiver, outline);
    canvas.drawPath(grip, outline);
  }

  void _drawFlash(
    Canvas canvas,
    Offset center, {
    double scale = 1.0,
  }) {
    final outer = Paint()..color = const Color(0xFFFF9800);
    final inner = Paint()..color = const Color(0xFFFFEB3B);
    final glow = Paint()..color = const Color(0xFFFFC107).withOpacity(.25);
    final smoke = Paint()..color = Colors.white.withOpacity(.12);

    final x = center.dx;
    final y = center.dy;

    canvas.drawCircle(
      Offset(x + 7, y),
      19 * scale,
      glow,
    );

    final burst = Path()
      ..moveTo(x, y - 9 * scale)
      ..lineTo(x + 10 * scale, y - 16 * scale)
      ..lineTo(x + 16 * scale, y - 6 * scale)
      ..lineTo(x + 29 * scale, y - 11 * scale)
      ..lineTo(x + 23 * scale, y)
      ..lineTo(x + 31 * scale, y + 10 * scale)
      ..lineTo(x + 16 * scale, y + 7 * scale)
      ..lineTo(x + 10 * scale, y + 17 * scale)
      ..lineTo(x, y + 8 * scale)
      ..lineTo(x + 4 * scale, y)
      ..close();

    final innerBurst = Path()
      ..moveTo(x + 4 * scale, y - 5 * scale)
      ..lineTo(x + 12 * scale, y - 8 * scale)
      ..lineTo(x + 17 * scale, y)
      ..lineTo(x + 12 * scale, y + 8 * scale)
      ..lineTo(x + 4 * scale, y + 5 * scale)
      ..lineTo(x + 7 * scale, y)
      ..close();

    canvas.drawPath(burst, outer);
    canvas.drawPath(innerBurst, inner);

    canvas.drawCircle(
      Offset(x - 2 * scale, y - 8 * scale),
      5 * scale,
      smoke,
    );

    canvas.drawCircle(
      Offset(x + 4 * scale, y + 10 * scale),
      4 * scale,
      smoke,
    );
  }

  void _drawCasing(
    Canvas canvas,
    Offset position,
  ) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(shot.isEven ? -.45 : .4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 5, 11),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFFD6A94D),
    );

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 5, 2),
      Paint()..color = const Color(0xFFF5D47A),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WeaponPainter oldDelegate) {
    return oldDelegate.weapon.type != weapon.type ||
        oldDelegate.firing != firing ||
        oldDelegate.shot != shot ||
        oldDelegate.reloading != reloading ||
        oldDelegate.reloadProgress != reloadProgress;
  }
}
