// lib/data/sensor_database.dart

import 'models.dart';

// Lista koja sadrži sve senzore i njihove podatke
final sensorDatabase = <BaseSensorData>[
  NtcSensor(
    id: 'ECT-01',
    name: 'ECT Senzor (2-pin)',
    category: TestCategory.sensors,
    ntcTable: [
      NtcDataPoint(temp: -20, resistance: 15000),
      NtcDataPoint(temp: 0, resistance: 5800),
      NtcDataPoint(temp: 20, resistance: 2450),
      NtcDataPoint(temp: 40, resistance: 1150),
      NtcDataPoint(temp: 80, resistance: 320),
      NtcDataPoint(temp: 100, resistance: 185),
    ],
    alarms: [
      AlarmTemp(model: '4-TEC', temp: 105),
      AlarmTemp(model: 'ACE', temp: 107),
    ],
    resistanceTest: ResistanceTest(refMin: 180, refMax: 15500),
    voltageTest: VoltageTest(description: "Testirati napon signala prema ECU.")
  ),
  SwitchSensor(
    id: 'VTS-SW-01',
    name: 'VTS Prekidač (UP/DOWN)',
    category: TestCategory.sensors,
    typeDescription: 'Prekidač na volanu',
    principleOfOperation: "Pritiskom na tipku zatvara se krug prema masi.",
    activationRange: "0 Ω kod pritiska, beskonačno inače.",
    resistanceTest: ResistanceTest(refMin: 0, refMax: 1),
  ),
  // ... dodajte sve ostale vaše senzore ovdje
];


// ISPRAVAK: Logika za grupiranje je sada unutar funkcije koja kreira mapu.
// Ovo rješava sintaktičku grešku 'for' petlje.
final Map<TestCategory, List<BaseSensorData>> groupedSensors = _groupSensors();

Map<TestCategory, List<BaseSensorData>> _groupSensors() {
  final map = <TestCategory, List<BaseSensorData>>{};
  for (var sensor in sensorDatabase) {
    if (!map.containsKey(sensor.category)) {
      map[sensor.category] = [];
    }
    map[sensor.category]!.add(sensor);
  }
  return map;
}