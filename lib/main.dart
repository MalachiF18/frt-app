import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const GunRangeApp());

class GunRangeApp extends StatelessWidget {
  const GunRangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pocket Range',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC18A4A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WeaponSelectScreen(),
    );
  }
}

enum WeaponType {
  glock19x,
  glock17,
  riflePistol,
  dp12,
}

class WeaponSpec {
  const WeaponSpec({
    required this.type,
    required this.name,
    required this.subtitle,
    required this.capacity,
    required this.accent,
  });

  final WeaponType type;
  final String name;
  final String subtitle;
  final int capacity;
  final Color accent;
}

const weapons = <WeaponSpec>[
  WeaponSpec(
    type: WeaponType.glock19x,
    name: 'GLOCK 19X',
    subtitle: 'Peanut butter finish',
    capacity: 30,
    accent: Color(0xFFC18A4A),
  ),
  WeaponSpec(
    type: WeaponType.glock17,
    name: 'GLOCK 17',
    subtitle: 'All black',
    capacity: 17,
    accent: Color(0xFF747A80),
  ),
  WeaponSpec(
    type: WeaponType.riflePistol,
    name: 'AR PISTOL',
    subtitle: 'Dark red accents',
    capacity: 30,
    accent: Color(0xFF8D2430),
  ),
  WeaponSpec(
    type: WeaponType.dp12,
    name: 'DP-12 GEN 2',
    subtitle: 'Black double barrel',
    capacity: 16,
    accent: Color(0xFF565C61),
  ),
];

class WeaponSelectScreen extends StatelessWidget {
  const WeaponSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      appBar: AppBar(
        title: const Text(
          'CHOOSE YOUR WEAPON',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 700 ? 2 : 1;

          return GridView.builder(
            padding: const EdgeInsets.all(18),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 215,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: weapons.length,
            itemBuilder: (context, index) {
              final weapon = weapons[index];

              return _WeaponCard(
                weapon: weapon,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RangeScreen(
                        weapon: weapon,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WeaponCard extends StatelessWidget {
  const _WeaponCard({
    required this.weapon,
    required this.onTap,
  });

  final WeaponSpec weapon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      color: const Color(0xFF171A1D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: weapon.accent,
          width: 2,
        ),
      ),
      child: InkWell(
        key: Key('select-${weapon.type.name}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: CustomPaint(
                        size: const Size(290, 120),
                        painter: WeaponPainter(
                          weapon: weapon,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: weapon.accent.withOpacity(.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: weapon.accent.withOpacity(.65),
                          ),
                        ),
                        child: Text(
                          '${weapon.capacity} RDS',
                          style: TextStyle(
                            color: weapon.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                weapon.name,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weapon.subtitle,
                style: TextStyle(
                  color: weapon.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RangeScreen extends StatefulWidget {
  const RangeScreen({
    super.key,
    required this.weapon,
  });

  final WeaponSpec weapon;

  @override
  State<RangeScreen> createState() => _RangeScreenState();
}

class _RangeScreenState extends State<RangeScreen> {
  final _random = math.Random();
  final List<Offset> _hits = [];

  Timer? _fireTimer;

  late int _rounds;

  bool _rapidFire = false;
  bool _firing = false;

  int _shot = 0;

  @override
  void initState() {
    super.initState();
    _rounds = widget.weapon.capacity;
  }

  void _pressStart() {
    if (_rounds == 0) {
      return;
    }

    _fire();

    if (_rapidFire) {
      _fireTimer = Timer.periodic(
        const Duration(milliseconds: 110),
        (_) => _fire(),
      );
    }
  }

  void _fire() {
    if (_rounds == 0) {
      _pressEnd();
      return;
    }

    setState(() {
      _rounds--;
      _shot++;
      _firing = true;

      _hits.add(
        Offset(
          .5 + (_random.nextDouble() - .5) * .34,
          .5 + (_random.nextDouble() - .5) * .34,
        ),
      );
    });

    Future<void>.delayed(
      const Duration(milliseconds: 75),
      () {
        if (mounted) {
          setState(() {
            _firing = false;
          });
        }
      },
    );
  }

  void _pressEnd() {
    _fireTimer?.cancel();
    _fireTimer = null;
  }

  void _reload() {
    _pressEnd();

    setState(() {
      _rounds = widget.weapon.capacity;
    });
  }

  double _recoilX() {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return -10;

      case WeaponType.riflePistol:
        return -16;

      case WeaponType.dp12:
        return -22;
    }
  }

  double _recoilY() {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return 2;

      case WeaponType.riflePistol:
        return 4;

      case WeaponType.dp12:
        return 7;
    }
  }

  double _recoilAngle() {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return -0.035;

      case WeaponType.riflePistol:
        return -0.05;

      case WeaponType.dp12:
        return -0.075;
    }
  }

  double _recoilScale() {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return .992;

      case WeaponType.riflePistol:
        return .987;

      case WeaponType.dp12:
        return .98;
    }
  }

  @override
  void dispose() {
    _fireTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0B),
      appBar: AppBar(
        title: Text(widget.weapon.name),
        backgroundColor: const Color(0xFF17191B),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: RangePainter(
                    hits: _hits,
                  ),
                ),

                Align(
                  alignment: const Alignment(0, .72),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => _pressStart(),
                    onTapUp: (_) => _pressEnd(),
                    onTapCancel: _pressEnd,
                    child: AnimatedContainer(
                      key: const Key('fire-control'),
                      duration: const Duration(milliseconds: 70),
                      curve: Curves.easeOutCubic,
                      transformAlignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(
                          _firing ? _recoilX() : 0.0,
                          _firing ? _recoilY() : 0.0,
                        )
                        ..rotateZ(
                          _firing ? _recoilAngle() : 0.0,
                        )
                        ..scale(
                          _firing ? _recoilScale() : 1.0,
                        ),
                      child: CustomPaint(
                        size: const Size(360, 160),
                        painter: WeaponPainter(
                          weapon: widget.weapon,
                          firing: _firing,
                          shot: _shot,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.weapon.accent,
                      ),
                    ),
                    child: Text(
                      'AMMO  $_rounds / ${widget.weapon.capacity}',
                      key: const Key('ammo-count'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: const Color(0xFF17191B),
            padding: const EdgeInsets.fromLTRB(
              12,
              8,
              12,
              14,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        key: const Key('rapid-fire-switch'),
                        title: const Text(
                          'FRT / RAPID FIRE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          _rapidFire
                              ? 'ON — hold to fire'
                              : 'OFF — single shot',
                        ),
                        value: _rapidFire,
                        activeThumbColor: widget.weapon.accent,
                        onChanged: (value) {
                          _pressEnd();

                          setState(() {
                            _rapidFire = value;
                          });
                        },
                      ),
                    ),
                  ),

                  FilledButton.icon(
                    key: const Key('reload-button'),
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('RELOAD'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RangePainter extends CustomPainter {
  const RangePainter({
    required this.hits,
  });

  final List<Offset> hits;

  @override
  void paint(Canvas canvas, Size size) {
    final wall = Paint()
      ..color = const Color(0xFF55504A);

    canvas.drawRect(
      Offset.zero & size,
      wall,
    );

    final mortar = Paint()
      ..color = const Color(0xFF35322F)
      ..strokeWidth = 2;

    for (var y = 0.0; y < size.height; y += 42) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        mortar,
      );

      final shift =
          ((y / 42).round().isEven) ? 0.0 : 40.0;

      for (var x = shift; x < size.width; x += 80) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + 42),
          mortar,
        );
      }
    }

    final targetWidth = math.min(
      190.0,
      size.width * .48,
    );

    final targetHeight = targetWidth * 1.28;

    final target = Rect.fromCenter(
      center: Offset(
        size.width / 2,
        targetHeight / 2 + 28,
      ),
      width: targetWidth,
      height: targetHeight,
    );

    canvas.drawShadow(
      Path()..addRect(target),
      Colors.black,
      12,
      true,
    );

    canvas.drawRect(
      target,
      Paint()
        ..color = const Color(0xFFF0E5C7),
    );

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF202020);

    for (
      var radius = targetWidth * .1;
      radius < targetWidth * .42;
      radius += 20
    ) {
      canvas.drawCircle(
        target.center,
        radius,
        ring,
      );
    }

    canvas.drawCircle(
      target.center,
      7,
      Paint()
        ..color = const Color(0xFFD32F2F),
    );

    for (final hit in hits) {
      final point = Offset(
        target.left + hit.dx * target.width,
        target.top + hit.dy * target.height,
      );

      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = Colors.black,
      );

      canvas.drawCircle(
        point,
        7,
        Paint()
          ..color = const Color(0xFF202020)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant RangePainter oldDelegate,
  ) {
    return oldDelegate.hits.length != hits.length;
  }
}

class WeaponPainter extends CustomPainter {
  const WeaponPainter({
    required this.weapon,
    this.firing = false,
    this.shot = 0,
  });

  final WeaponSpec weapon;
  final bool firing;
  final int shot;

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

  // =========================================================
  // GLOCK 19X / GLOCK 17
  // =========================================================

  void _drawGlock(
    Canvas canvas, {
    required Color slideColor,
    required Color frameColor,
  }) {
    final black = Paint()
      ..color = const Color(0xFF0B0C0D);

    final slide = Paint()
      ..color = slideColor;

    final frame = Paint()
      ..color = frameColor;

    final outline = Paint()
      ..color = Colors.black.withOpacity(.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final detail = Paint()
      ..color = Colors.black.withOpacity(.35)
      ..strokeWidth = 2;

    // Main squared Glock slide
    final slideShape = RRect.fromRectAndRadius(
      const Rect.fromLTWH(
        65,
        42,
        222,
        34,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(
      slideShape,
      slide,
    );

    // Top of slide
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          73,
          38,
          196,
          7,
        ),
        const Radius.circular(2),
      ),
      slide,
    );

    // Muzzle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          281,
          49,
          20,
          20,
        ),
        const Radius.circular(3),
      ),
      black,
    );

    // Barrel opening
    canvas.drawOval(
      const Rect.fromLTWH(
        288,
        54,
        9,
        10,
      ),
      Paint()
        ..color = const Color(0xFF363A3D),
    );

    // Rear sight
    canvas.drawRect(
      const Rect.fromLTWH(
        78,
        34,
        12,
        8,
      ),
      black,
    );

    // Front sight
    canvas.drawRect(
      const Rect.fromLTWH(
        259,
        34,
        8,
        8,
      ),
      black,
    );

    // Ejection port
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          210,
          49,
          34,
          13,
        ),
        const Radius.circular(2),
      ),
      Paint()
        ..color = Colors.black.withOpacity(.28),
    );

    // Glock rear slide serrations
    for (double x = 78; x <= 108; x += 7) {
      canvas.drawLine(
        Offset(x, 48),
        Offset(x - 3, 70),
        Paint()
          ..color = Colors.black.withOpacity(.4)
          ..strokeWidth = 2.5,
      );
    }

    // Polymer lower frame
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

    canvas.drawPath(
      lowerFrame,
      frame,
    );

    // Trigger guard
    final triggerGuard = Path()
      ..moveTo(174, 81)
      ..quadraticBezierTo(
        207,
        79,
        221,
        91,
      )
      ..quadraticBezierTo(
        216,
        112,
        183,
        114,
      )
      ..quadraticBezierTo(
        163,
        112,
        159,
        99,
      );

    canvas.drawPath(
      triggerGuard,
      Paint()
        ..color = const Color(0xFF0B0C0D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Trigger
    final trigger = Path()
      ..moveTo(190, 88)
      ..quadraticBezierTo(
        187,
        102,
        198,
        108,
      );

    canvas.drawPath(
      trigger,
      Paint()
        ..color = const Color(0xFF0B0C0D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Glock grip
    final grip = Path()
      ..moveTo(118, 88)
      ..lineTo(168, 88)
      ..lineTo(177, 101)
      ..lineTo(166, 148)
      ..lineTo(118, 146)
      ..lineTo(105, 106)
      ..close();

    canvas.drawPath(
      grip,
      frame,
    );

    // Back strap
    canvas.drawLine(
      const Offset(119, 94),
      const Offset(123, 141),
      detail,
    );

    // Grip texture lines
    for (double y = 103; y <= 135; y += 8) {
      canvas.drawLine(
        Offset(124, y),
        Offset(161, y + 3),
        Paint()
          ..color = Colors.black.withOpacity(.22)
          ..strokeWidth = 2,
      );
    }

    // Grip dots
    for (double y = 106; y <= 134; y += 9) {
      for (double x = 128; x <= 157; x += 9) {
        canvas.drawCircle(
          Offset(x, y),
          1.2,
          Paint()
            ..color = Colors.black.withOpacity(.25),
        );
      }
    }

    // Magazine base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          114,
          143,
          57,
          8,
        ),
        const Radius.circular(2),
      ),
      black,
    );

    // Accessory rail
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

    // Cartoon outline
    canvas.drawRRect(
      slideShape,
      outline,
    );

    canvas.drawPath(
      lowerFrame,
      outline,
    );

    canvas.drawPath(
      grip,
      outline,
    );
  }

  // =========================================================
  // AR PISTOL
  // =========================================================

  void _drawArPistol(Canvas canvas) {
    final body = Paint()
      ..color = const Color(0xFF292D31);

    final darker = Paint()
      ..color = const Color(0xFF151719);

    final accent = Paint()
      ..color = weapon.accent;

    final outline = Paint()
      ..color = Colors.black.withOpacity(.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Rear brace
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

    canvas.drawPath(
      brace,
      darker,
    );

    // Buffer tube
    canvas.drawRect(
      const Rect.fromLTWH(
        82,
        65,
        38,
        8,
      ),
      darker,
    );

    // Main receiver
    final receiver = RRect.fromRectAndRadius(
      const Rect.fromLTWH(
        112,
        56,
        96,
        29,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(
      receiver,
      body,
    );

    // Upper handguard
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          205,
          58,
          73,
          23,
        ),
        const Radius.circular(3),
      ),
      body,
    );

    // Barrel
    canvas.drawRect(
      const Rect.fromLTWH(
        277,
        65,
        46,
        8,
      ),
      darker,
    );

    // Muzzle device
    canvas.drawRect(
      const Rect.fromLTWH(
        320,
        61,
        10,
        16,
      ),
      accent,
    );

    // Rail
    canvas.drawRect(
      const Rect.fromLTWH(
        118,
        49,
        158,
        6,
      ),
      darker,
    );

    // Rail notches
    for (double x = 125; x < 267; x += 13) {
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          46,
          6,
          4,
        ),
        accent,
      );
    }

    // Cartoon optic
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          152,
          34,
          28,
          17,
        ),
        const Radius.circular(4),
      ),
      accent,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        160,
        29,
        12,
        7,
      ),
      darker,
    );

    // Magazine
    final magazine = Path()
      ..moveTo(162, 84)
      ..lineTo(193, 84)
      ..lineTo(190, 101)
      ..lineTo(182, 124)
      ..lineTo(151, 116)
      ..lineTo(154, 97)
      ..close();

    canvas.drawPath(
      magazine,
      darker,
    );

    // Magazine accent
    canvas.drawLine(
      const Offset(160, 93),
      const Offset(185, 99),
      Paint()
        ..color = weapon.accent.withOpacity(.7)
        ..strokeWidth = 3,
    );

    // Pistol grip
    final grip = Path()
      ..moveTo(129, 83)
      ..lineTo(153, 83)
      ..lineTo(148, 128)
      ..lineTo(124, 122)
      ..close();

    canvas.drawPath(
      grip,
      accent,
    );

    // Forward grip
    final forwardGrip = Path()
      ..moveTo(225, 80)
      ..lineTo(243, 80)
      ..lineTo(240, 108)
      ..lineTo(224, 107)
      ..close();

    canvas.drawPath(
      forwardGrip,
      accent,
    );

    // Ejection port
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          174,
          62,
          27,
          11,
        ),
        const Radius.circular(2),
      ),
      darker,
    );

    // Small controls
    canvas.drawCircle(
      const Offset(145, 72),
      4,
      accent,
    );

    // Outlines
    canvas.drawPath(
      brace,
      outline,
    );

    canvas.drawRRect(
      receiver,
      outline,
    );

    canvas.drawPath(
      magazine,
      outline,
    );

    canvas.drawPath(
      grip,
      outline,
    );
  }

  // =========================================================
  // DP-12
  // =========================================================

  void _drawDp12(Canvas canvas) {
    final body = Paint()
      ..color = const Color(0xFF151719);

    final dark = Paint()
      ..color = const Color(0xFF262A2E);

    final accent = Paint()
      ..color = weapon.accent;

    final outline = Paint()
      ..color = Colors.black.withOpacity(.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Stock
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

    canvas.drawPath(
      stock,
      dark,
    );

    // Main receiver
    final receiver = RRect.fromRectAndRadius(
      const Rect.fromLTWH(
        92,
        55,
        121,
        38,
      ),
      const Radius.circular(9),
    );

    canvas.drawRRect(
      receiver,
      body,
    );

    // Top rail
    canvas.drawRect(
      const Rect.fromLTWH(
        111,
        48,
        98,
        6,
      ),
      dark,
    );

    for (double x = 119; x <= 197; x += 13) {
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          45,
          7,
          4,
        ),
        accent,
      );
    }

    // Pump section
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          187,
          58,
          55,
          30,
        ),
        const Radius.circular(5),
      ),
      accent,
    );

    // Pump grooves
    for (double x = 194; x <= 231; x += 9) {
      canvas.drawLine(
        Offset(x, 62),
        Offset(x, 84),
        Paint()
          ..color = Colors.black.withOpacity(.28)
          ..strokeWidth = 2,
      );
    }

    // Top barrel
    canvas.drawRect(
      const Rect.fromLTWH(
        241,
        63,
        88,
        8,
      ),
      dark,
    );

    // Bottom barrel
    canvas.drawRect(
      const Rect.fromLTWH(
        241,
        77,
        88,
        8,
      ),
      dark,
    );

    // Barrel tips
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          327,
          61,
          9,
          12,
        ),
        const Radius.circular(2),
      ),
      body,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          327,
          75,
          9,
          12,
        ),
        const Radius.circular(2),
      ),
      body,
    );

    // Receiver detail
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          118,
          62,
          42,
          13,
        ),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.white.withOpacity(.09),
    );

    // Pistol grip
    final grip = Path()
      ..moveTo(155, 90)
      ..lineTo(185, 90)
      ..lineTo(177, 134)
      ..lineTo(150, 129)
      ..close();

    canvas.drawPath(
      grip,
      dark,
    );

    // Trigger guard
    canvas.drawOval(
      const Rect.fromLTWH(
        168,
        80,
        39,
        27,
      ),
      Paint()
        ..color = const Color(0xFF08090A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Trigger
    canvas.drawLine(
      const Offset(187, 88),
      const Offset(184, 101),
      Paint()
        ..color = const Color(0xFF08090A)
        ..strokeWidth = 3,
    );

    // Outlines
    canvas.drawPath(
      stock,
      outline,
    );

    canvas.drawRRect(
      receiver,
      outline,
    );

    canvas.drawPath(
      grip,
      outline,
    );
  }

  // =========================================================
  // MUZZLE FLASH
  // =========================================================

  void _drawFlash(
    Canvas canvas,
    Offset center, {
    double scale = 1.0,
  }) {
    final outer = Paint()
      ..color = const Color(0xFFFF9800);

    final inner = Paint()
      ..color = const Color(0xFFFFEB3B);

    final glow = Paint()
      ..color = const Color(0xFFFFC107)
          .withOpacity(.25);

    final smoke = Paint()
      ..color = Colors.white.withOpacity(.12);

    final x = center.dx;
    final y = center.dy;

    canvas.drawCircle(
      Offset(
        x + 7,
        y,
      ),
      19 * scale,
      glow,
    );

    final burst = Path()
      ..moveTo(
        x,
        y - 9 * scale,
      )
      ..lineTo(
        x + 10 * scale,
        y - 16 * scale,
      )
      ..lineTo(
        x + 16 * scale,
        y - 6 * scale,
      )
      ..lineTo(
        x + 29 * scale,
        y - 11 * scale,
      )
      ..lineTo(
        x + 23 * scale,
        y,
      )
      ..lineTo(
        x + 31 * scale,
        y + 10 * scale,
      )
      ..lineTo(
        x + 16 * scale,
        y + 7 * scale,
      )
      ..lineTo(
        x + 10 * scale,
        y + 17 * scale,
      )
      ..lineTo(
        x,
        y + 8 * scale,
      )
      ..lineTo(
        x + 4 * scale,
        y,
      )
      ..close();

    final innerBurst = Path()
      ..moveTo(
        x + 4 * scale,
        y - 5 * scale,
      )
      ..lineTo(
        x + 12 * scale,
        y - 8 * scale,
      )
      ..lineTo(
        x + 17 * scale,
        y,
      )
      ..lineTo(
        x + 12 * scale,
        y + 8 * scale,
      )
      ..lineTo(
        x + 4 * scale,
        y + 5 * scale,
      )
      ..lineTo(
        x + 7 * scale,
        y,
      )
      ..close();

    canvas.drawPath(
      burst,
      outer,
    );

    canvas.drawPath(
      innerBurst,
      inner,
    );

    canvas.drawCircle(
      Offset(
        x - 2 * scale,
        y - 8 * scale,
      ),
      5 * scale,
      smoke,
    );

    canvas.drawCircle(
      Offset(
        x + 4 * scale,
        y + 10 * scale,
      ),
      4 * scale,
      smoke,
    );
  }

  // =========================================================
  // SHELL CASING
  // =========================================================

  void _drawCasing(
    Canvas canvas,
    Offset position,
  ) {
    canvas.save();

    canvas.translate(
      position.dx,
      position.dy,
    );

    canvas.rotate(
      shot.isEven ? -.45 : .4,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          0,
          0,
          5,
          11,
        ),
        const Radius.circular(1),
      ),
      Paint()
        ..color = const Color(0xFFD6A94D),
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        0,
        0,
        5,
        2,
      ),
      Paint()
        ..color = const Color(0xFFF5D47A),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
    covariant WeaponPainter oldDelegate,
  ) {
    return oldDelegate.weapon.type != weapon.type ||
        oldDelegate.firing != firing ||
        oldDelegate.shot != shot;
  }
}