import 'package:flutter/material.dart';
import '../models/weapon_spec.dart';
import 'painters/weapon_painter.dart';

class WeaponCard extends StatelessWidget {
  const WeaponCard({
    super.key,
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
