// lib/models.dart - KOMPLETNA VERZIJA S IBR_POSITION
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

// ------------------------------------------------------------------
// --- MODEL ZA LIVE MJERENJE SENZORA (koristi se za V/A graf) ---
class LiveData {
  final double measuredVoltage;
  final double measuredCurrent;

  LiveData({
    this.measuredVoltage = 0.0,
    this.measuredCurrent = 0.0,
  });

  static LiveData initial() => LiveData();

  factory LiveData.fromJson(Map<String, dynamic> json) {
    return LiveData(
      measuredVoltage: (json['Voltage'] ?? 0.0).toDouble(),
      measuredCurrent: (json['Current'] ?? 0.0).toDouble(),
    );
  }
}

// ------------------------------------------------------------------
// --- NOVI MODEL ZA LIVE CAN DASHBOARD ---
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
  // PROMJENA (Točka 10): Mjenjač (gear) zamijenjen s IBR Pozicijom
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
    this.ibrPosition = 0.0, // Inicijalna vrijednost
  });

  static CanLiveData initial() => CanLiveData();

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
      // PROMJENA: Očekujemo 'ibrPosition' umjesto 'gear'
      ibrPosition: (json['ibrPosition'] ?? 0.0).toDouble(),
    );
  }
}

// ------------------------------------------------------------------
// --- MODEL ZA SPECIFIKACIJU I TRENUTNO MJERENJE OTpora SENZORA ---
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

  TemperatureSensorSpec copyWith({
    double? measuredResistance,
    String? status,
  }) {
    return TemperatureSensorSpec(
      id: id,
      name: name,
      ecuPinout: ecuPinout,
      resistanceTable: resistanceTable,
      measuredResistance: measuredResistance ?? this.measuredResistance,
      status: status ?? this.status,
    );
  }
}
