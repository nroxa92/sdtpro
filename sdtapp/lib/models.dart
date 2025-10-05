import 'package:flutter/material.dart';

// --- MODELI ZA STRUKTURU I NAVIGACIJU IZBORNIKA ---
class MainMenuCategory {
  final String name;
  final IconData icon;
  final List<SubCategoryItem> subCategories;

  MainMenuCategory({
    required this.name,
    required this.icon,
    required this.subCategories,
  });
}

class SubCategoryItem {
  final String name;
  final String? description;
  final String routeName;

  SubCategoryItem({
    required this.name,
    required this.routeName,
    this.description,
  });
}

// --- MODEL ZA STATUS SPOJENOG POD-a ---
// (Premješteno iz websocket_service.dart)
class PodStatus {
  final int id;
  final String name;
  final Color color;

  PodStatus({
    this.id = 0,
    this.name = 'Nije Uključeno',
    this.color = Colors.grey,
  });
}

// ------------------------------------------------------------------
// --- MODELI ZA LIVE PODATKE ---
// ------------------------------------------------------------------

// --- NOVI MODEL: Live podaci specifično za ECU POD (EB1) ---
class EcuPodData {
  // Napajanje i Mase
  final double pinH2Voltage;
  final double pinM4Voltage;
  final bool pinL1GndStatus;
  final bool pinM2GndStatus;
  final bool pinM3GndStatus;

  // Start Sustav
  final bool pinD1Continuity;
  final double pinD1Resistance;
  final bool pinL4GndStatus;

  // Sustav Goriva
  final bool pinM1GndStatus;

  // DESS Ključ
  final bool pinF2GndStatus;

  // NTC Senzori
  final double egtsResistance;
  final double egtsVoltage;
  final double ltsResistance;
  final double ltsVoltage;

  // CAN Sabirnica (Test Linije)
  final double canResistance;
  final double canHVoltage;
  final double canLVoltage;

  // TPS Senzori
  final double tps1Voltage5V;
  final bool tps1GndStatus;
  final double tps1SignalVoltage;
  final double tps2Voltage5V;
  final bool tps2GndStatus;
  final double tps2SignalVoltage;

  // Konstruktor s početnim (default) vrijednostima
  EcuPodData({
    this.pinH2Voltage = 0.0,
    this.pinM4Voltage = 0.0,
    this.pinL1GndStatus = false,
    this.pinM2GndStatus = false,
    this.pinM3GndStatus = false,
    this.pinD1Continuity = false,
    this.pinD1Resistance = 0.0,
    this.pinL4GndStatus = false,
    this.pinM1GndStatus = false,
    this.pinF2GndStatus = false,
    this.egtsResistance = 0.0,
    this.egtsVoltage = 0.0,
    this.ltsResistance = 0.0,
    this.ltsVoltage = 0.0,
    this.canResistance = 0.0,
    this.canHVoltage = 0.0,
    this.canLVoltage = 0.0,
    this.tps1Voltage5V = 0.0,
    this.tps1GndStatus = false,
    this.tps1SignalVoltage = 0.0,
    this.tps2Voltage5V = 0.0,
    this.tps2GndStatus = false,
    this.tps2SignalVoltage = 0.0,
  });

  // Factory konstruktor za kreiranje objekta iz JSON-a koji šalje firmware
  factory EcuPodData.fromJson(Map<String, dynamic> json) {
    return EcuPodData(
      pinH2Voltage: (json['h2_v'] ?? 0.0).toDouble(),
      pinM4Voltage: (json['m4_v'] ?? 0.0).toDouble(),
      pinL1GndStatus: json['l1_gnd'] ?? false,
      pinM2GndStatus: json['m2_gnd'] ?? false,
      pinM3GndStatus: json['m3_gnd'] ?? false,
      pinD1Continuity: json['d1_cont'] ?? false,
      pinD1Resistance: (json['d1_res'] ?? 0.0).toDouble(),
      pinL4GndStatus: json['l4_gnd'] ?? false,
      pinM1GndStatus: json['m1_gnd'] ?? false,
      pinF2GndStatus: json['f2_gnd'] ?? false,
      egtsResistance: (json['egts_res'] ?? 0.0).toDouble(),
      egtsVoltage: (json['egts_v'] ?? 0.0).toDouble(),
      ltsResistance: (json['lts_res'] ?? 0.0).toDouble(),
      ltsVoltage: (json['lts_v'] ?? 0.0).toDouble(),
      canResistance: (json['can_res'] ?? 0.0).toDouble(),
      canHVoltage: (json['can_h_v'] ?? 0.0).toDouble(),
      canLVoltage: (json['can_l_v'] ?? 0.0).toDouble(),
      tps1Voltage5V: (json['tps1_5v'] ?? 0.0).toDouble(),
      tps1GndStatus: json['tps1_gnd'] ?? false,
      tps1SignalVoltage: (json['tps1_sig_v'] ?? 0.0).toDouble(),
      tps2Voltage5V: (json['tps2_5v'] ?? 0.0).toDouble(),
      tps2GndStatus: json['tps2_gnd'] ?? false,
      tps2SignalVoltage: (json['tps2_sig_v'] ?? 0.0).toDouble(),
    );
  }
}

// --- POSTOJEĆI MODELI ---
class LiveData {
  final double measuredVoltage;
  final double measuredCurrent;

  LiveData({
    this.measuredVoltage = 0.0,
    this.measuredCurrent = 0.0,
  });

  factory LiveData.fromJson(Map<String, dynamic> json) {
    return LiveData(
      measuredVoltage: (json['Voltage'] ?? 0.0).toDouble(),
      measuredCurrent: (json['Current'] ?? 0.0).toDouble(),
    );
  }
}

class CanLiveData {
  final double rpm;
  final double throttlePercent;
  final double coolantTemp;
  final double oilTemp;
  final double speedKmh;
  final double fuelLevel;
  final double mapKpa;
  final double intakeTemp;
  final double exhaustTemp;
  final double batteryVoltage;
  final double ibrPosition;

  CanLiveData({
    this.rpm = 0.0,
    this.throttlePercent = 0.0,
    this.coolantTemp = 0.0,
    this.oilTemp = 0.0,
    this.speedKmh = 0.0,
    this.fuelLevel = 0.0,
    this.mapKpa = 0.0,
    this.intakeTemp = 0.0,
    this.exhaustTemp = 0.0,
    this.batteryVoltage = 0.0,
    this.ibrPosition = 0.0,
  });

  factory CanLiveData.fromJson(Map<String, dynamic> json) {
    return CanLiveData(
      rpm: (json['rpm'] ?? 0.0).toDouble(),
      throttlePercent: (json['throttlePercent'] ?? 0.0).toDouble(),
      coolantTemp: (json['coolantTemp'] ?? 0.0).toDouble(),
      oilTemp: (json['oilTemp'] ?? 0.0).toDouble(),
      speedKmh: (json['speedKmh'] ?? 0.0).toDouble(),
      fuelLevel: (json['fuelLevel'] ?? 0.0).toDouble(),
      mapKpa: (json['mapKpa'] ?? 0.0).toDouble(),
      intakeTemp: (json['intakeTemp'] ?? 0.0).toDouble(),
      exhaustTemp: (json['exhaustTemp'] ?? 0.0).toDouble(),
      batteryVoltage: (json['batteryVoltage'] ?? 0.0).toDouble(),
      ibrPosition: (json['ibrPosition'] ?? 0.0).toDouble(),
    );
  }
}

class TemperatureSensorSpec {
  final String id;
  final String name;
  final String ecuPinout;
  final Map<int, int> resistanceTable;

  double? measuredResistance;
  String status;

  TemperatureSensorSpec({
    required this.id,
    required this.name,
    required this.ecuPinout,
    required this.resistanceTable,
    this.measuredResistance,
    this.status = 'pending',
  });
}
