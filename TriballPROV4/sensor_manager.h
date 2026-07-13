// sensor_manager.h
#ifndef SENSOR_MANAGER_H
#define SENSOR_MANAGER_H

#include <Arduino.h>
#include "config.h"

class SensorManager {
public:
  SensorManager();

  void begin();
  void scan();    // À appeler très souvent depuis loop()

  // Returns true if a NEW detection was made (one-shot)
  bool hasNewDetection();

  // Detection data (valide après hasNewDetection() == true)
  String  getDetectedHole();
  int     getDetectedValue();
  String  getDetectedEffect();
  uint8_t getDetectedSensor();

  void enable();
  void disable();
  bool isEnabled() const { return _enabled; }

  void reset();

private:
  bool _enabled;

  // État interne par capteur
  bool          _lastState[IR_SENSOR_COUNT];        // état lu précédent
  bool          _stableState[IR_SENSOR_COUNT];      // état après debounce
  unsigned long _lastChangeTime[IR_SENSOR_COUNT];   // ms du dernier changement
  unsigned long _lastDetectionTime[IR_SENSOR_COUNT];

  // Dernière détection
  bool    _newDetection;
  String  _detHole;
  int     _detValue;
  String  _detEffect;
  uint8_t _detSensor;

  // Helpers
  bool _isTriggered(int rawState);
  String _holeIdForIndex(uint8_t index);
  int _valueForIndex(uint8_t index);
  String _effectForIndex(uint8_t index);
};

#endif