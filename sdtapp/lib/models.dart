// lib/data/models.dart
import 'package:flutter/material.dart';

// --- MODELI ZA STRUKTURU I NAVIGACIJU IZBORNIKA ---
// Ovi modeli ostaju nepromijenjeni (MainMenuCategory i SubCategoryItem)
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
// --- MODEL ZA LIVE CAN PODATKE (koristi se za graf) ---
// Sadrži samo generičke polja za live mjerenje Napona/Struje
// Hardver će slati podatke o trenutno odabranom senzoru u ovim poljima.
class LiveData {
  // Napon i struja trenutno odabranog senzora
  final double measuredVoltage;
  final double measuredCurrent;

  LiveData({
    this.measuredVoltage = 0.0,
    this.measuredCurrent = 0.0,
  });

  static LiveData initial() => LiveData();

  // Tvornička metoda za stvaranje objekta iz JSON-a
  // Hardver će slati JSON poput: {"Voltage": 2.75, "Current": 0.003}
  factory LiveData.fromJson(Map<String, dynamic> json) {
    return LiveData(
      measuredVoltage: (json['Voltage'] ?? 0.0).toDouble(),
      measuredCurrent: (json['Current'] ?? 0.0).toDouble(),
    );
  }
}

// ------------------------------------------------------------------
// --- MODEL ZA SPECIFIKACIJU I TRENUTNO MJERENJE OTpora SENZORA ---
// Sadrži statičke (pinout) i dinamičke (measuredResistance, status) podatke
class TemperatureSensorSpec {
  final String id; // EGTS, ECTS, itd.
  final String name;
  final String ecuPinout;
  final Map<int, int> resistanceTable; // {Temp_C: Nominalni_Otpor_Ohms}

  // Dinamička polja za prikaz na ekranu Otpora
  double? measuredResistance;
  String status; // 'ok', 'error', 'pending'

  TemperatureSensorSpec({
    required this.id,
    required this.name,
    required this.ecuPinout,
    required this.resistanceTable,
    this.measuredResistance,
    this.status = 'pending',
  });

  // Metoda za kreiranje kopije objekta s novim dinamičkim podacima
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
