import 'models.dart';

final sensorDatabase = <BaseSensorData>[
  
  // === SENZORI ===
  NtcSensor(
    id: 'NTC-GENERIC', name: 'Senzori Temperature', category: TestCategory.senzori,
    typeDescription: "NTC Otpornik",
    resistanceTest: ResistanceTest(refMin: 1200, refMax: 2500, unit: "Ω @ 20-40°C"),
    voltageTest: VoltageTest(description: "Očekivani napon: 2.7V - 3.6V (procjena)"),
    ntcTable: [
      NtcDataPoint(temp: 20, resistance: 2500), NtcDataPoint(temp: 25, resistance: 2100),
      NtcDataPoint(temp: 30, resistance: 1700), NtcDataPoint(temp: 35, resistance: 1450),
      NtcDataPoint(temp: 40, resistance: 1200),
    ],
    alarms: [
      AlarmTemp(model: "Alarm Vode (1.5L)", temp: 100),
      AlarmTemp(model: "Alarm Vode (1.6L, ne 300hp)", temp: 102),
      // ... ostali alarmi
    ],
  ),
  InductiveSensor(
    id: 'CPS-01', name: 'CPS - Senzor Radilice', category: TestCategory.senzori,
    typeDescription: 'Induktivni senzor',
    resistanceTest: ResistanceTest(refMin: 775, refMax: 900),
    staticVoltage: "~3.7V DC (referenca iz ECU)",
    liveSignal: "~2.3V AC (sinusoidni val pri verglanju)",
  ),
  PiezoSensor(
    id: 'KNOCK-01', name: 'Knock Senzor', category: TestCategory.senzori,
    typeDescription: 'Piezoelektrični senzor',
    resistanceTest: ResistanceTest(refMin: 4, refMax: 6, unit: "MΩ"),
    liveSignal: 'Mali AC napon pri vibraciji motora.',
  ),
  HallSensor(
    id: 'CAPS-01', name: 'CAPS - Senzor Bregaste', category: TestCategory.senzori,
    typeDescription: 'Hall senzor',
    pinout: [ PinoutDetail(pin: 1, description: 'Masa (GND)'), PinoutDetail(pin: 2, description: 'Signal (za ECU)'), PinoutDetail(pin: 3, description: 'Napajanje (+12V)'), ],
    liveSignal: 'Digitalni pravokutni signal (~12V HIGH, ~0V LOW).',
  ),
  ComboSensor(
    id: 'MAPTS-01', name: 'MAPTS - Pritisak i Temp. Usisa', category: TestCategory.senzori,
    typeDescription: 'Kombinirani senzor (MAP + NTC)',
    pinout: [ PinoutDetail(pin: 1, description: 'Masa (GND)'), PinoutDetail(pin: 2, description: 'Signal Temperature (NTC)'), PinoutDetail(pin: 3, description: 'Signal Tlaka (MAP)'), PinoutDetail(pin: 4, description: 'Napajanje (+5V)'), ],
    tempSignalInfo: 'Analogni DC napon, prati NTC tablicu.',
    pressureSignalInfo: 'Analogni DC napon (~4.5V na atm. tlaku, pada prema ~0.5V s vakuumom).',
  ),

  // === IN KOMPONENTE ===
  SwitchSensor(
    id: 'OIL-PRESS-SW', name: 'Senzor Pritiska Ulja', category: TestCategory.in_komponente,
    typeDescription: 'Prekidač (Normally Closed)',
    principleOfOperation: 'Spojen na masu kada motor ne radi. Prekida krug kada pritisak poraste.',
    activationRange: '1.8 - 2.2 bar',
    resistanceTest: ResistanceTest(refMin: 0, refMax: 1, unit: "Ω (ugašen motor)"),
  ),
  // TODO: Ovdje dodajte ostale IN komponente (npr. VTS prekidač)

  // === OUT KOMPONENTE ===
  GenericSensor(
    id: 'INJ-01', name: 'Injektor Goriva', category: TestCategory.out_komponente,
    typeDescription: 'Elektromagnetski ventil',
    resistanceTest: ResistanceTest(refMin: 11.4, refMax: 12.6),
    voltageTest: VoltageTest(description: "~12V DC"),
  ),
  GenericSensor(
    id: 'IGN-COIL-OLD', name: 'Bobina (Stari tip)', category: TestCategory.out_komponente,
    typeDescription: 'Indukcijski svitak',
    resistanceTest: ResistanceTest(refMin: 0.85, refMax: 1.15),
  ),
  GenericSensor(
    id: 'IGN-COIL-NEW', name: 'Bobina (Novi tip)', category: TestCategory.out_komponente,
    typeDescription: 'Indukcijski svitak s igniterom',
    pinout: [ PinoutDetail(pin: 1, description: 'Masa (GND)'), PinoutDetail(pin: 2, description: 'Signal (ECU)'), PinoutDetail(pin: 3, description: 'Napajanje (+12V)'), ],
  ),
  
  // === CAN "FAKE" UNOSI (da se gumbi prikažu) ===
  GenericSensor(id: 'CAN-LIVE', name: 'CAN Live Data', category: TestCategory.can_live, typeDescription: 'Prikaz podataka u stvarnom vremenu.'),
  GenericSensor(id: 'CAN-ERR', name: 'CAN Greške', category: TestCategory.can_errors, typeDescription: 'Čitanje i brisanje grešaka motora.'),
  GenericSensor(id: 'CAN-TEST', name: 'CAN Testovi', category: TestCategory.can_testovi, typeDescription: 'Aktivacija komponenti putem CAN bus-a.'),
];

// Ostatak datoteke ostaje nepromijenjen
final Map<TestCategory, List<BaseSensorData>> groupedSensors = _groupSensors();
Map<TestCategory, List<BaseSensorData>> _groupSensors() { /* ... */ }