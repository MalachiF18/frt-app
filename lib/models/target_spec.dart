import 'package:flutter/material.dart';

enum TargetType {
  bullseye,
  steelGong,
  silhouette,
}

extension TargetTypeExtension on TargetType {
  String get label {
    switch (this) {
      case TargetType.bullseye:
        return 'Bullseye';
      case TargetType.steelGong:
        return 'Steel Gong';
      case TargetType.silhouette:
        return 'Silhouette';
    }
  }

  IconData get icon {
    switch (this) {
      case TargetType.bullseye:
        return Icons.adjust;
      case TargetType.steelGong:
        return Icons.shield;
      case TargetType.silhouette:
        return Icons.person;
    }
  }
}

enum TargetDistance {
  yd7,
  yd15,
  yd25,
}

extension TargetDistanceExtension on TargetDistance {
  String get label {
    switch (this) {
      case TargetDistance.yd7:
        return '7 YDS';
      case TargetDistance.yd15:
        return '15 YDS';
      case TargetDistance.yd25:
        return '25 YDS';
    }
  }

  double get scaleFactor {
    switch (this) {
      case TargetDistance.yd7:
        return 1.0;
      case TargetDistance.yd15:
        return 0.78;
      case TargetDistance.yd25:
        return 0.58;
    }
  }

  double get dispersionFactor {
    switch (this) {
      case TargetDistance.yd7:
        return 1.0;
      case TargetDistance.yd15:
        return 1.45;
      case TargetDistance.yd25:
        return 2.1;
    }
  }
}

class TargetScoring {
  static int calculateScore(Offset hitRatio, TargetType type) {
    // hitRatio dx and dy are 0.0 to 1.0 relative to target rect
    final distFromCenter = (Offset(hitRatio.dx - 0.5, hitRatio.dy - 0.5)).distance;

    switch (type) {
      case TargetType.bullseye:
        if (distFromCenter <= 0.05) return 10;
        if (distFromCenter <= 0.12) return 9;
        if (distFromCenter <= 0.20) return 8;
        if (distFromCenter <= 0.28) return 7;
        if (distFromCenter <= 0.38) return 5;
        return 0;

      case TargetType.steelGong:
        return distFromCenter <= 0.40 ? 10 : 0;

      case TargetType.silhouette:
        // Headshot area (top center)
        final headDist = (Offset(hitRatio.dx - 0.5, hitRatio.dy - 0.22)).distance;
        if (headDist <= 0.12) return 10;
        // Center mass area
        final chestDist = (Offset(hitRatio.dx - 0.5, hitRatio.dy - 0.52)).distance;
        if (chestDist <= 0.22) return 10;
        if (chestDist <= 0.36) return 7;
        return 0;
    }
  }
}
