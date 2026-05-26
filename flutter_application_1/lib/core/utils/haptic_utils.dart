import 'package:flutter/services.dart';

abstract final class HapticUtils {
  static Future<void> light() => HapticFeedback.lightImpact();

  static Future<void> medium() => HapticFeedback.mediumImpact();

  static Future<void> heavy() => HapticFeedback.heavyImpact();

  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }
}
