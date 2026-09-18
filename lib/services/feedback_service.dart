import 'package:flutter/services.dart';

class FeedbackService {
  const FeedbackService();

  void triggerFireHaptic() {
    HapticFeedback.heavyImpact();
  }

  void triggerReloadHaptic() {
    HapticFeedback.mediumImpact();
  }

  void triggerClickHaptic() {
    HapticFeedback.selectionClick();
  }

  void triggerSteelImpactHaptic() {
    HapticFeedback.vibrate();
  }
}
