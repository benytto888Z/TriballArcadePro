// lib/core/constants/audio_constants.dart

class AudioConstants {
  // ============================================
  // SFX POOL SIZE
  // ============================================
  /// Nombre de players SFX en parallèle (permet plusieurs sons simultanés)
  static const int sfxPoolSize = 4;

  // ============================================
  // DEFAULT VOLUMES
  // ============================================
  static const double defaultSfxVolume = 0.8;
  static const double defaultBgmVolume = 0.4;
  static const double defaultVoiceVolume = 1.0;
  static const double defaultVoicePitch = 1.0;
  static const double defaultVoiceRate = 0.5;

  // ============================================
  // RANGES
  // ============================================
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double minPitch = 0.5;
  static const double maxPitch = 2.0;
  static const double minRate = 0.1;
  static const double maxRate = 1.0;

  // ============================================
  // SAMPLE TTS PHRASES (per language)
  // ============================================
  static const Map<String, String> ttsTestPhrases = {
    'fr': 'Bonjour, je suis le système vocal de Triball Arcade',
    'en': 'Hello, I am the voice system of Triball Arcade',
    'es': 'Hola, soy el sistema de voz de Triball Arcade',
    'de': 'Hallo, ich bin das Sprachsystem von Triball Arcade',
  };
}