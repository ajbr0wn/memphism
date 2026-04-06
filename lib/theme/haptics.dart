import 'package:vibration/vibration.dart';

/// Haptic feedback patterns for mathematical interactions.
/// Each operation has a distinct feel.
class Haptics {
  Haptics._();

  /// Light tap — selecting a node.
  static Future<void> tap() =>
      Vibration.vibrate(duration: 10, amplitude: 80);

  /// Snap — connecting an arrow to a node.
  static Future<void> snap() =>
      Vibration.vibrate(duration: 25, amplitude: 180);

  /// Composition success — two morphisms compose.
  static Future<void> compose() =>
      Vibration.vibrate(pattern: [0, 30, 40, 30], intensities: [0, 200, 0, 255]);

  /// Error/fizzle — invalid composition.
  static Future<void> fizzle() =>
      Vibration.vibrate(pattern: [0, 15, 20, 15, 20, 15], intensities: [0, 100, 0, 60, 0, 40]);

  /// Level complete — resonant chord feeling.
  static Future<void> triumph() =>
      Vibration.vibrate(pattern: [0, 40, 60, 40, 60, 80], intensities: [0, 180, 0, 220, 0, 255]);

  /// Identity morphism discovered — a deep pulse.
  static Future<void> identity() =>
      Vibration.vibrate(duration: 50, amplitude: 140);

  /// Notation reveal — gentle emergence.
  static Future<void> reveal() =>
      Vibration.vibrate(duration: 20, amplitude: 100);
}
