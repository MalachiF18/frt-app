import 'package:flutter/material.dart';
import '../models/weapon_spec.dart';
import '../widgets/weapon_card.dart';
import 'range_screen.dart';

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

              return WeaponCard(
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
