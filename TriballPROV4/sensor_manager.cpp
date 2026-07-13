// sensor_manager.cpp
#include "sensor_manager.h"

SensorManager::SensorManager()
  : _enabled(false),
    _newDetection(false),
    _detValue(0),
    _detSensor(0)
{
  for (int i = 0; i < IR_SENSOR_COUNT; i++) {
    _lastState[i] = false;
    _stableState[i] = false;
    _lastChangeTime[i] = 0;
    _lastDetectionTime[i] = 0;
  }
}

void SensorManager::begin() {
  for (int i = 0; i < IR_SENSOR_COUNT; i++) {
    pinMode(IR_PINS[i], INPUT_PULLUP);
    int raw = digitalRead(IR_PINS[i]);
    _lastState[i]   = _isTriggered(raw);
    _stableState[i] = _lastState[i];
  }
  if (DEBUG_SERIAL) {
    Serial.printf("📡 SensorManager initialized (%d IR sensors)\n",
                  IR_SENSOR_COUNT);
    Serial.println("📌 Sensor pins:");
    for (int i = 0; i < IR_SENSOR_COUNT; i++) {
      Serial.printf("   #%d → GPIO %d (%s)\n",
                    i, IR_PINS[i], _holeIdForIndex(i).c_str());
    }
  }
}

void SensorManager::enable()  { _enabled = true;  reset(); }
void SensorManager::disable() { _enabled = false; }

void SensorManager::reset() {
  for (int i = 0; i < IR_SENSOR_COUNT; i++) {
    _lastDetectionTime[i] = 0;
  }
  _newDetection = false;
}

bool SensorManager::_isTriggered(int rawState) {
  // Si IR_ACTIVE_LOW = true, LOW signifie "détecté"
  return IR_ACTIVE_LOW ? (rawState == LOW) : (rawState == HIGH);
}

void SensorManager::scan() {
  if (!_enabled) return;
  if (_newDetection) return; // attend que Flutter consomme

  unsigned long now = millis();

  for (uint8_t i = 0; i < IR_SENSOR_COUNT; i++) {
    // Cooldown post-détection
    if (now - _lastDetectionTime[i] < DETECTION_COOLDOWN) continue;

    int raw = digitalRead(IR_PINS[i]);
    bool current = _isTriggered(raw);

    // === Debounce ===
    if (current != _lastState[i]) {
      _lastChangeTime[i] = now;
      _lastState[i] = current;
    }

    // Si l'état est stable depuis DEBOUNCE_MS
    if ((now - _lastChangeTime[i]) >= DEBOUNCE_MS) {
      if (_stableState[i] != current) {
        _stableState[i] = current;

        // Front montant : objet détecté (passage de pas-détecté → détecté)
        if (current) {
          _detSensor   = i;
          _detHole     = _holeIdForIndex(i);
          _detValue    = _valueForIndex(i);
          _detEffect   = _effectForIndex(i);
          _newDetection = true;
          _lastDetectionTime[i] = now;

          if (DEBUG_SERIAL) {
            Serial.printf("🎯 DETECT sensor=%u hole=%s val=%d effect=%s\n",
                          i, _detHole.c_str(), _detValue, _detEffect.c_str());
          }
          return; // 1 détection par scan
        }
      }
    }
  }
}

bool SensorManager::hasNewDetection() {
  if (_newDetection) {
    _newDetection = false;
    return true;
  }
  return false;
}

String  SensorManager::getDetectedHole()   { return _detHole; }
int     SensorManager::getDetectedValue()  { return _detValue; }
String  SensorManager::getDetectedEffect() { return _detEffect; }
uint8_t SensorManager::getDetectedSensor() { return _detSensor; }

// ============================================
// MAPPING : index → hole ID
// ============================================
String SensorManager::_holeIdForIndex(uint8_t i) {
  switch (i) {
    case 0: return HOLE_LEFT_TOP;
    case 1: return HOLE_CENTER_TOP;
    case 2: return HOLE_RIGHT_TOP;
    case 3: return HOLE_LEFT_MID;
    case 4: return HOLE_CENTER_MID;
    case 5: return HOLE_RIGHT_MID;
    case 6: return HOLE_LEFT_LOW;
    case 7: return HOLE_CENTER_LOW;
    case 8: return HOLE_RIGHT_LOW;
  }
  return "UNKNOWN";
}

int SensorManager::_valueForIndex(uint8_t i) {
  switch (i) {
    case 0: return VAL_LEFT_TOP;
    case 1: return VAL_CENTER_TOP;
    case 2: return VAL_RIGHT_TOP;
    case 3: return VAL_LEFT_MID;
    case 4: return VAL_CENTER_MID;
    case 5: return VAL_RIGHT_MID;
    case 6: return VAL_LEFT_LOW;
    case 7: return VAL_CENTER_LOW;
    case 8: return VAL_RIGHT_LOW;
  }
  return 0;
}

String SensorManager::_effectForIndex(uint8_t i) {
  if (i == 7) return "x0";          // CENTER_LOW
  if (i == 8) return "x2";          // RIGHT_LOW
  int v = _valueForIndex(i);
  if (v > 0) return "positive";
  if (v < 0) return "negative";
  return "neutral";
}