import 'package:flutter/material.dart';
import '../models/target_spec.dart';

class TargetControlsBar extends StatelessWidget {
  const TargetControlsBar({
    super.key,
    required this.targetType,
    required this.targetDistance,
    required this.onTargetTypeChanged,
    required this.onTargetDistanceChanged,
    required this.onResetTarget,
    required this.accentColor,
  });

  final TargetType targetType;
  final TargetDistance targetDistance;
  final ValueChanged<TargetType> onTargetTypeChanged;
  final ValueChanged<TargetDistance> onTargetDistanceChanged;
  final VoidCallback onResetTarget;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color(0xFF101214),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Reset Target Button
            IconButton.filledTonal(
              key: const Key('reset-target-button'),
              tooltip: 'Reset Target',
              onPressed: onResetTarget,
              icon: const Icon(Icons.delete_outline, size: 20),
              style: IconButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 8),

            // Target Type Selector Segmented Button / Chips
            DropdownButton<TargetType>(
              key: const Key('target-type-dropdown'),
              value: targetType,
              dropdownColor: const Color(0xFF1E2228),
              underline: const SizedBox.shrink(),
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              icon: Icon(Icons.arrow_drop_down, color: accentColor),
              items: TargetType.values.map((type) {
                return DropdownMenuItem<TargetType>(
                  value: type,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 16, color: accentColor),
                      const SizedBox(width: 6),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newType) {
                if (newType != null) onTargetTypeChanged(newType);
              },
            ),

            const SizedBox(width: 12),
            Container(height: 20, width: 1, color: Colors.white24),
            const SizedBox(width: 12),

            // Target Distance Selector
            SegmentedButton<TargetDistance>(
              key: const Key('target-distance-segmented'),
              segments: TargetDistance.values.map((dist) {
                return ButtonSegment<TargetDistance>(
                  value: dist,
                  label: Text(
                    dist.label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              selected: {targetDistance},
              onSelectionChanged: (selection) {
                onTargetDistanceChanged(selection.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return accentColor.withOpacity(0.25);
                  }
                  return Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return accentColor;
                  }
                  return Colors.white70;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
