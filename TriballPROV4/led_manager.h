// led_manager.h
#ifndef LED_MANAGER_H
#define LED_MANAGER_H

#include <Arduino.h>
#include <Adafruit_NeoPixel.h>
#include "config.h"

class LedManager {
public:
  LedManager();
  void begin();
  void update();

  void setAll(uint8_t r, uint8_t g, uint8_t b);
  void clear();
  void setHole(int holeIndex, uint8_t r, uint8_t g, uint8_t b);

  void showStartup();
  void showReady();
  void showGameActive();
  void showGameStopped();
  void showGameReset();
  void flashHole(const String& holeId, const String& effect, int value);
  void enableIdleAnimation(bool enable) { _idleAnim = enable; }

private:
  Adafruit_NeoPixel _leds;
  bool _idleAnim;
  unsigned long _lastAnimUpdate;
  unsigned long _flashHoleUntil[9];
  uint32_t _flashColor[9];

  int _holeNameToIndex(const String& holeId);
  void _writeHole(int idx, uint8_t r, uint8_t g, uint8_t b);
};

#endif