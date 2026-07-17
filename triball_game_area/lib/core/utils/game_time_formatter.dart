/// Source unique de formatage des durées de TRIBALL.
///
/// - Écrans de jeu et de victoire : mm:ss
/// - Podium et Top 10 : mm:ss.cc (centièmes)
class GameTimeFormatter {
  const GameTimeFormatter._();

  static String mmSs(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static String mmSsHundredths(Duration duration) {
    final hundredths =
        (duration.inMilliseconds.remainder(1000) ~/ 10).clamp(0, 99);
    return '${mmSs(duration)}.${hundredths.toString().padLeft(2, '0')}';
  }

  /// Construit la durée officielle du classement.
  /// Les secondes viennent exclusivement du compteur affiché dans GameScreen.
  /// Seule la fraction de seconde vient de la mesure précise.
  static Duration officialDuration({
    required int displayedSeconds,
    required Duration preciseMeasurement,
  }) {
    final safeSeconds = displayedSeconds < 0 ? 0 : displayedSeconds;
    final fractionMs = preciseMeasurement.inMilliseconds.remainder(1000);
    return Duration(
      milliseconds: safeSeconds * 1000 + fractionMs,
    );
  }
}
