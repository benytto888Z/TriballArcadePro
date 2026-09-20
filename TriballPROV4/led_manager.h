// led_manager.h
#ifndef LED_MANAGER_H
#define LED_MANAGER_H

#include <Arduino.h>
#include <Adafruit_NeoPixel.h>
#include "config.h"

struct ColorRGB {
  uint8_t r;
  uint8_t g;
  uint8_t b;
};

class LedManager {
public:
  LedManager();
  void begin();
  void update();
  void setAll(uint8_t r, uint8_t g, uint8_t b);
  void clear();
  void setHole(int holeIndex, uint8_t r, uint8_t g, uint8_t b);
  void restoreHole(int holeIndex);
  void showStartup();
  void showReady();
  void showGameActive();
  void showGameStopped();
  void showGameReset();
  void flashHole(const String& holeId, const String& effect = "", int value = 0);
  void enableIdleAnimation(bool enable) { _idleAnim = enable; }

private:
  Adafruit_NeoPixel _leds;
  bool _idleAnim;
  unsigned long _lastAnimUpdate;
  
  unsigned long _flashHoleUntil[9];
  ColorRGB _flashColor[9];
  
  // Tableau des 9 couleurs par défaut selon l'ordre demandé
  static const ColorRGB DEFAULT_HOLE_COLORS[9];

  int _holeNameToIndex(const String& holeId);
  void _writeHole(int idx, uint8_t r, uint8_t g, uint8_t b);
  void _restoreHole(int idx);
};

#endif