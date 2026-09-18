import 'package:flutter/material.dart';
import 'screens/weapon_select_screen.dart';

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