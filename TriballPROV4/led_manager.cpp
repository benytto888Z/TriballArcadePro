// led_manager.cpp
#include "led_manager.h"

// Définition des couleurs initiales pour chaque trou
// {bleu, orange, vert, orange, jaune, orange, bleu, violet, cyan}
const ColorRGB LedManager::DEFAULT_HOLE_COLORS[9] = {
  {0,   0,   255},  // 0: Bleu
  {255, 120, 0  },  // 1: Orange
  {0,   255, 0  },  // 2: Vert
  {255, 120, 0  },  // 3: Orange
  {255, 220, 0  },  // 4: Jaune
  {255, 120, 0  },  // 5: Orange
  {0,   0,   255},  // 6: Bleu
  {180, 0,   255},  // 7: Violet
  {0,   255, 255}   // 8: Cyan
};

/*const ColorRGB LedManager::DEFAULT_HOLE_COLORS[9] = {
  {0,   0,   0},  // 0: Bleu
  {0, 0, 0  },  // 1: Orange
  {0,   0, 0  },  // 2: Vert
  {0, 0, 0  },  // 3: Orange
  {0, 0, 0  },  // 4: Jaune
  {0, 0, 0  },  // 5: Orange
  {0,   0,   0},  // 6: Bleu
  {0, 0,   0},  // 7: Violet
  {0,   0, 0}   // 8: Cyan
};*/

LedManager::LedManager()
  : _leds(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800),
    _idleAnim(false),
    _lastAnimUpdate(0)
{
  for (int i = 0; i < 9; i++) {
    _flashHoleUntil[i] = 0;
    _flashColor[i] = {255, 255, 255};
  }
}

void LedManager::begin() {
  _leds.begin();
  _leds.setBrightness(LED_BRIGHTNESS);
  _leds.clear();
  _leds.show();
  showStartup();
  if (DEBUG_SERIAL) {
    Serial.printf("💡 LedManager initialized (%d pixels)\n", LED_COUNT);
  }
}

void LedManager::update() {
  unsigned long now = millis();
  bool needShow = false;

  // Gestion des flashs des trous (1.5 sec)
  for (int i = 0; i < 9; i++) {
    if (_flashHoleUntil[i] != 0) {
      if (now >= _flashHoleUntil[i]) {
        // Le flash est terminé -> retour à la couleur initiale
        _flashHoleUntil[i] = 0;
        _restoreHole(i);
      } else {
        // Effet stroboscope dynamique (clignotement toutes les 75ms)
        bool flashState = ((now / 75) % 2) == 0;
        if (flashState) {
          _writeHole(i, _flashColor[i].r, _flashColor[i].g, _flashColor[i].b);
        } else {
          _writeHole(i, 0, 0, 0); // Éteint brièvement pour l'effet de flash
        }
      }
    }
  }

  // Animation d'attente (Idle) si activée
  if (_idleAnim && (now - _lastAnimUpdate > 50)) {
    _lastAnimUpdate = now;
    static uint16_t hue = 0;
    hue += 256;
    for (int i = 0; i < LED_COUNT; i++) {
      uint32_t c = _leds.gamma32(_leds.ColorHSV(hue + i * 1024));
      _leds.setPixelColor(i, c);
    }
    _leds.show();
  }
}

void LedManager::setAll(uint8_t r, uint8_t g, uint8_t b) {
  _idleAnim = false;
  for (int i = 0; i < LED_COUNT; i++) {
    _leds.setPixelColor(i, _leds.Color(r, g, b));
  }
  _leds.show();
}

void LedManager::clear() {
  _idleAnim = false;
  _leds.clear();
  _leds.show();
}

void LedManager::setHole(int holeIndex, uint8_t r, uint8_t g, uint8_t b) {
  if (holeIndex < 0 || holeIndex >= 9) return;
  _writeHole(holeIndex, r, g, b);
}

void LedManager::restoreHole(int holeIndex) {
  _restoreHole(holeIndex);
}

void LedManager::_restoreHole(int idx) {
  if (idx < 0 || idx >= 9) return;
  _writeHole(idx, 
             DEFAULT_HOLE_COLORS[idx].r, 
             DEFAULT_HOLE_COLORS[idx].g, 
             DEFAULT_HOLE_COLORS[idx].b);
}

void LedManager::_writeHole(int idx, uint8_t r, uint8_t g, uint8_t b) {
  int startLED = idx * 10;
  for (int i = 0; i < 10; i++) {
    int led = startLED + i;
    if (led < LED_COUNT) {
      _leds.setPixelColor(led, _leds.Color(r, g, b));
    }
  }
  _leds.show();
}

void LedManager::showStartup() {
  _idleAnim = false;
  for (int i = 0; i < LED_COUNT; i++) {
    _leds.setPixelColor(i, _leds.Color(0, 255, 255));
    _leds.show();
    delay(10);
  }
  delay(200);
  for (int i = LED_COUNT - 1; i >= 0; i--) {
    _leds.setPixelColor(i, 0);
    _leds.show();
    delay(10);
  }
}

void LedManager::showReady() {
  _idleAnim = true;
  if (DEBUG_SERIAL) Serial.println("💡 LED READY (idle rainbow)");
}

void LedManager::showGameActive() {
  _idleAnim = false;
  // Allumer chaque trou avec sa couleur assignée
  for (int i = 0; i < 9; i++) {
    _flashHoleUntil[i] = 0;
    _restoreHole(i);
  }
  if (DEBUG_SERIAL) Serial.println("💡 LED GAME ACTIVE (Couleurs par trou activées)");
}

void LedManager::showGameStopped() {
  _idleAnim = false;
  setAll(80, 0, 0);
  if (DEBUG_SERIAL) Serial.println("💡 LED GAME STOPPED");
}

void LedManager::showGameReset() {
  setAll(0, 0, 255);
  delay(300);
  showGameActive();
}

void LedManager::flashHole(const String& holeId, const String& effect, int value) {
  int idx = _holeNameToIndex(holeId);
  if (idx < 0) return;

  // Flash blanc éclatant par défaut
  uint8_t r = 255, g = 255, b = 255;

  // Ajustement optionnel si effet spécial
  if (effect == "x0" || effect == "negative") {
    r = 255; g = 0; b = 0; // Rouge pour malus
  } else if (effect == "x2") {
    r = 255; g = 215; b = 0; // Or pour bonus
  }

  _flashColor[idx] = {r, g, b};
  
  // Flash d'une durée exacte de 1.5 seconde (1500 ms)
  _flashHoleUntil[idx] = millis() + 1500; 

  if (DEBUG_SERIAL) {
    Serial.printf("🎯 Hole %s (idx: %d) flash 1.5s triggered\n", holeId.c_str(), idx);
  }
}

int LedManager::_holeNameToIndex(const String& holeId) {
  if (holeId == HOLE_LEFT_TOP)   return 0;
  if (holeId == HOLE_CENTER_TOP) return 1;
  if (holeId == HOLE_RIGHT_TOP)  return 2;
  if (holeId == HOLE_LEFT_MID)   return 3;
  if (holeId == HOLE_CENTER_MID) return 4;
  if (holeId == HOLE_RIGHT_MID)  return 5;
  if (holeId == HOLE_LEFT_LOW)   return 6;
  if (holeId == HOLE_CENTER_LOW) return 7;
  if (holeId == HOLE_RIGHT_LOW)  return 8;
  return -1;
}