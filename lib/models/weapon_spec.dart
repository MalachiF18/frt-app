import 'package:flutter/material.dart';

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

const List<WeaponSpec> weapons = <WeaponSpec>[
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

class HitMark {
  const HitMark({
    required this.offset,
    required this.score,
    required this.timestamp,
    required this.shotIndex,
  });

  final Offset offset;
  final int score;
  final DateTime timestamp;
  final int shotIndex;
}
