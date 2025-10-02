enum TestCategory {
  senzori("Senzori"),
  inKomponente("IN Komponente"),
  outKomponente("OUT Komponente"),
  canLive("CAN Live Data"),
  canErrors("CAN Greške"),
  canTestovi("CAN Testovi");

  const TestCategory(this.displayName);
  final String displayName;
}

class ResistanceTest {
  final double refMin;
  final double refMax;
  final String unit;
  ResistanceTest({required this.refMin, required this.refMax, this.unit = "Ω"});
}

class VoltageTest {
  final String description;
  final String type;
  VoltageTest({required this.description, this.type = "DC"});
}

class CurrentTest {
  final double refMin;
  final double refMax;
  CurrentTest({required this.refMin, required this.refMax});
}

class PinoutDetail {
  final int pin;
  final String description;
  PinoutDetail({required this.pin, required this.description});
}

class NtcDataPoint {
  final int temp;
  final int resistance;
  NtcDataPoint({required this.temp, required this.resistance});
}

class AlarmTemp {
  final String model;
  final double temp;
  AlarmTemp({required this.model, required this.temp});
}

abstract class BaseSensorData {
  final String id;
  final String name;
  final TestCategory category;
  final String typeDescription;
  final String principleOfOperation;
  final List<String> notes;
  final ResistanceTest? resistanceTest;
  final VoltageTest? voltageTest;
  final CurrentTest? currentTest;
  final List<PinoutDetail>? pinout;

  BaseSensorData({
    required this.id,
    required this.name,
    required this.category,
    required this.typeDescription,
    this.principleOfOperation = "",
    this.notes = const [],
    this.resistanceTest,
    this.voltageTest,
    this.currentTest,
    this.pinout,
  });
}

class GenericSensor extends BaseSensorData {
  GenericSensor({
    required super.id,
    required super.name,
    required super.category,
    required super.typeDescription,
    super.principleOfOperation,
    super.notes,
    super.resistanceTest,
    super.voltageTest,
    super.currentTest,
    super.pinout,
  });
}

class NtcSensor extends BaseSensorData {
  final List<NtcDataPoint> ntcTable;
  final List<AlarmTemp> alarms;

  NtcSensor({
    required super.id,
    required super.name,
    required super.category,
    super.typeDescription = "NTC Otpornik",
    required this.ntcTable,
    required this.alarms,
    super.resistanceTest,
    super.voltageTest,
    super.currentTest,
  });
}

class SwitchSensor extends BaseSensorData {
  final String activationRange;
  SwitchSensor({
    required super.id,
    required super.name,
    required super.category,
    required super.typeDescription,
    required super.principleOfOperation,
    required this.activationRange,
    super.notes,
    super.resistanceTest,
  });
}

class InductiveSensor extends BaseSensorData {
  final String staticVoltage;
  final String liveSignal;
  InductiveSensor({
    required super.id,
    required super.name,
    required super.category,
    required super.typeDescription,
    required this.staticVoltage,
    required this.liveSignal,
    super.resistanceTest,
  });
}

class PiezoSensor extends BaseSensorData {
  final String liveSignal;
  PiezoSensor({
    required super.id,
    required super.name,
    required super.category,
    required super.typeDescription,
    required this.liveSignal,
    super.resistanceTest,
    super.notes,
  });
}

class HallSensor extends BaseSensorData {
  final String liveSignal;
  HallSensor({
    required super.id,
    required super.name,
    required super.category,
    required super.typeDescription,
    required this.liveSignal,
    super.pinout,
  });
}

class ComboSensor extends BaseSensorData {
  final String tempSignalInfo;
  final String pressureSignalInfo;
  ComboSensor({
    required super.id,
    required super.name,
    required super.category,
    required super.typeDescription,
    required this.tempSignalInfo,
    required this.pressureSignalInfo,
    super.pinout,
  });
}