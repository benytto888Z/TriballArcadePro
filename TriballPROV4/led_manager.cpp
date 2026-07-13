// led_manager.cpp
#include "led_manager.h"

LedManager::LedManager()
  : _leds(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800),
    _idleAnim(false),
    _lastAnimUpdate(0)
{
  for (int i = 0; i < 9; i++) {
    _flashHoleUntil[i] = 0;
    _flashColor[i] = 0;
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

  for (int i = 0; i < 9; i++) {
    if (_flashHoleUntil[i] != 0 && now >= _flashHoleUntil[i]) {
      _writeHole(i, 0, 0, 0);
      _flashHoleUntil[i] = 0;
    }
  }

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

void LedManager::_writeHole(int idx, uint8_t r, uint8_t g, uint8_t b) {
  int startLED = idx * 3;
  for (int i = 0; i < 3; i++) {
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
    delay(20);
  }
  delay(300);
  for (int i = LED_COUNT - 1; i >= 0; i--) {
    _leds.setPixelColor(i, 0);
    _leds.show();
    delay(15);
  }
}

void LedManager::showReady() {
  _idleAnim = true;
  if (DEBUG_SERIAL) Serial.println("💡 LED READY (idle rainbow)");
}

void LedManager::showGameActive() {
  setAll(0, 80, 0);
  if (DEBUG_SERIAL) Serial.println("💡 LED GAME ACTIVE");
}

void LedManager::showGameStopped() {
  setAll(80, 0, 0);
  if (DEBUG_SERIAL) Serial.println("💡 LED GAME STOPPED");
}

void LedManager::showGameReset() {
  setAll(0, 0, 255);
  delay(400);
  showGameActive();
}

void LedManager::flashHole(const String& holeId, const String& effect, int value) {
  int idx = _holeNameToIndex(holeId);
  if (idx < 0) return;

  uint8_t r = 0, g = 255, b = 0;

  if (effect == "x0") {
    r = 255; g = 0; b = 0;
  } else if (effect == "x2") {
    r = 255; g = 215; b = 0;
  } else if (effect == "negative") {
    r = 255; g = 0; b = 0;
  } else if (value >= 30) {
    r = 0; g = 255; b = 255;
  } else if (value > 0) {
    r = 0; g = 255; b = 0;
  }

  _writeHole(idx, r, g, b);
  _flashColor[idx] = _leds.Color(r, g, b);
    Serial.println("Detected ok ok ok");
  _flashHoleUntil[idx] = millis() + LED_FLASH_DURATION;


}

int LedManager::_holeNameToIndex(const String& holeId) {
  if (holeId == HOLE_LEFT_TOP)    return 0;
  if (holeId == HOLE_CENTER_TOP)  return 1;
  if (holeId == HOLE_RIGHT_TOP)   return 2;
  if (holeId == HOLE_LEFT_MID)    return 3;
  if (holeId == HOLE_CENTER_MID)  return 4;
  if (holeId == HOLE_RIGHT_MID)   return 5;
  if (holeId == HOLE_LEFT_LOW)    return 6;
  if (holeId == HOLE_CENTER_LOW)  return 7;
  if (holeId == HOLE_RIGHT_LOW)   return 8;
  return -1;
}