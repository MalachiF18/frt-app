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

enum WeaponType { glock19x, glock17, riflePistol, dp12 }

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
        title: const Text('CHOOSE YOUR WEAPON'),
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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => RangeScreen(weapon: weapon),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _WeaponCard extends StatelessWidget {
  const _WeaponCard({required this.weapon, required this.onTap});

  final WeaponSpec weapon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF171A1D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: weapon.accent, width: 2),
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
                child: Center(
                  child: CustomPaint(
                    size: const Size(290, 120),
                    painter: WeaponPainter(weapon: weapon),
                  ),
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
              Text(
                '${weapon.subtitle}  •  ${weapon.capacity} rounds',
                style: TextStyle(color: weapon.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RangeScreen extends StatefulWidget {
  const RangeScreen({super.key, required this.weapon});

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
    if (_rounds == 0) return;
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
    Future<void>.delayed(const Duration(milliseconds: 60), () {
      if (mounted) setState(() => _firing = false);
    });
  }

  void _pressEnd() {
    _fireTimer?.cancel();
    _fireTimer = null;
  }

  void _reload() {
    _pressEnd();
    setState(() => _rounds = widget.weapon.capacity);
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
                  painter: RangePainter(hits: _hits),
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
                      duration: const Duration(milliseconds: 45),
                      transform: Matrix4.translationValues(
                        _firing ? -13 : 0,
                        _firing ? 4 : 0,
                        0,
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
                      border: Border.all(color: widget.weapon.accent),
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
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _rapidFire ? 'ON — hold to fire' : 'OFF — single shot',
                        ),
                        value: _rapidFire,
                        activeThumbColor: widget.weapon.accent,
                        onChanged: (value) {
                          _pressEnd();
                          setState(() => _rapidFire = value);
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
  const RangePainter({required this.hits});

  final List<Offset> hits;

  @override
  void paint(Canvas canvas, Size size) {
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

    final targetWidth = math.min(190.0, size.width * .48);
    final targetHeight = targetWidth * 1.28;
    final target = Rect.fromCenter(
      center: Offset(size.width / 2, targetHeight / 2 + 28),
      width: targetWidth,
      height: targetHeight,
    );
    canvas.drawShadow(
      Path()..addRect(target),
      Colors.black,
      12,
      true,
    );
    canvas.drawRect(target, Paint()..color = const Color(0xFFF0E5C7));
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF202020);
    for (var radius = targetWidth * .1; radius < targetWidth * .42; radius += 20) {
      canvas.drawCircle(target.center, radius, ring);
    }
    canvas.drawCircle(target.center, 7, Paint()..color = const Color(0xFFD32F2F));
    for (final hit in hits) {
      final point = Offset(
        target.left + hit.dx * target.width,
        target.top + hit.dy * target.height,
      );
      canvas.drawCircle(point, 4, Paint()..color = Colors.black);
      canvas.drawCircle(point, 7, ring..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant RangePainter oldDelegate) =>
      oldDelegate.hits.length != hits.length;
}

class WeaponPainter extends CustomPainter {
  const WeaponPainter({required this.weapon, this.firing = false, this.shot = 0});

  final WeaponSpec weapon;
  final bool firing;
  final int shot;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 160);
    final black = Paint()..color = const Color(0xFF151719);
    final dark = Paint()..color = const Color(0xFF2A2D30);
    final accent = Paint()..color = weapon.accent;
    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    switch (weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        final body = weapon.type == WeaponType.glock19x ? accent : black;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(55, 38, 235, 48),
            const Radius.circular(7),
          ),
          body,
        );
        canvas.drawRect(const Rect.fromLTWH(290, 50, 35, 18), black);
        final grip = Path()
          ..moveTo(202, 82)
          ..lineTo(264, 82)
          ..lineTo(280, 151)
          ..lineTo(214, 151)
          ..lineTo(188, 98)
          ..close();
        canvas.drawPath(grip, body);
        canvas.drawOval(const Rect.fromLTWH(132, 76, 75, 45), outline);
        canvas.drawArc(const Rect.fromLTWH(153, 82, 32, 35), 0, math.pi, false, outline);
        if (weapon.type == WeaponType.glock19x) {
          canvas.drawRect(const Rect.fromLTWH(216, 143, 66, 17), black);
        }
      case WeaponType.riflePistol:
        canvas.drawRect(const Rect.fromLTWH(66, 47, 215, 42), dark);
        canvas.drawRect(const Rect.fromLTWH(281, 55, 66, 16), black);
        canvas.drawRect(const Rect.fromLTWH(105, 36, 75, 12), accent);
        canvas.drawRect(const Rect.fromLTWH(50, 54, 28, 28), accent);
        final mag = Path()
          ..moveTo(205, 87)
          ..lineTo(252, 87)
          ..lineTo(265, 147)
          ..lineTo(220, 147)
          ..close();
        canvas.drawPath(mag, black);
        final grip = Path()
          ..moveTo(157, 87)
          ..lineTo(195, 87)
          ..lineTo(183, 137)
          ..lineTo(145, 137)
          ..close();
        canvas.drawPath(grip, accent);
      case WeaponType.dp12:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(45, 48, 235, 57),
            const Radius.circular(12),
          ),
          black,
        );
        canvas.drawRect(const Rect.fromLTWH(270, 55, 78, 12), dark);
        canvas.drawRect(const Rect.fromLTWH(270, 78, 78, 12), dark);
        canvas.drawRect(const Rect.fromLTWH(95, 56, 92, 41), accent);
        final stock = Path()
          ..moveTo(48, 56)
          ..lineTo(8, 66)
          ..lineTo(5, 107)
          ..lineTo(65, 98)
          ..close();
        canvas.drawPath(stock, black);
        final grip = Path()
          ..moveTo(202, 99)
          ..lineTo(248, 99)
          ..lineTo(235, 151)
          ..lineTo(194, 151)
          ..close();
        canvas.drawPath(grip, dark);
    }

    if (firing) {
      final flash = Paint()..color = const Color(0xFFFFB300);
      final tip = weapon.type == WeaponType.dp12 ? 352.0 : 330.0;
      final y = weapon.type == WeaponType.dp12 && shot.isOdd ? 84.0 : 60.0;
      final burst = Path()
        ..moveTo(tip, y - 10)
        ..lineTo(tip + 28, y - 25)
        ..lineTo(tip + 18, y)
        ..lineTo(tip + 32, y + 21)
        ..lineTo(tip, y + 11)
        ..close();
      canvas.drawPath(burst, flash);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WeaponPainter oldDelegate) =>
      oldDelegate.weapon.type != weapon.type ||
      oldDelegate.firing != firing ||
      oldDelegate.shot != shot;
}
