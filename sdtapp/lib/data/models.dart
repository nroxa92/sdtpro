import 'package:flutter/material.dart';
// Uklanjamo Hive import odavde jer pripada u 'sensor_data.dart'
// a ne u općenite modele za UI

// --- MODELI ZA STRUKTURU I NAVIGACIJU IZBORNIKA ---
// Ovo ostaje isto kao i prije
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

// --- AŽURIRANI MODEL ZA LIVE CAN PODATKE ---
class LiveData {
  // Otpori
  final double egtsResistance;
  final double ectsResistance;
  final double eotsResistance;
  final double matsResistance;
  final double ltsResistance;

  // Naponi
  final double egtsVoltage;
  final double ectsVoltage;
  final double eotsVoltage;
  final double matsVoltage;
  final double ltsVoltage;

  // Struje
  final double egtsCurrent;
  final double ectsCurrent;
  final double eotsCurrent;
  final double matsCurrent;
  final double ltsCurrent;

  LiveData({
    // Otpori
    this.egtsResistance = 0.0,
    this.ectsResistance = 0.0,
    this.eotsResistance = 0.0,
    this.matsResistance = 0.0,
    this.ltsResistance = 0.0,
    // Naponi
    this.egtsVoltage = 0.0,
    this.ectsVoltage = 0.0,
    this.eotsVoltage = 0.0,
    this.matsVoltage = 0.0,
    this.ltsVoltage = 0.0,
    // Struje
    this.egtsCurrent = 0.0,
    this.ectsCurrent = 0.0,
    this.eotsCurrent = 0.0,
    this.matsCurrent = 0.0,
    this.ltsCurrent = 0.0,
  });

  // Tvornička metoda za stvaranje objekta iz JSON-a
  // Ključevi moraju točno odgovarati onome što šalje firmware!
  factory LiveData.fromJson(Map<String, dynamic> json) {
    return LiveData(
      // Otpori
      egtsResistance: (json['egts_res'] ?? 0.0).toDouble(),
      ectsResistance: (json['ects_res'] ?? 0.0).toDouble(),
      eotsResistance: (json['eots_res'] ?? 0.0).toDouble(),
      matsResistance: (json['mats_res'] ?? 0.0).toDouble(),
      ltsResistance: (json['lts_res'] ?? 0.0).toDouble(),
      // Naponi
      egtsVoltage: (json['egts_v'] ?? 0.0).toDouble(),
      ectsVoltage: (json['ects_v'] ?? 0.0).toDouble(),
      eotsVoltage: (json['eots_v'] ?? 0.0).toDouble(),
      matsVoltage: (json['mats_v'] ?? 0.0).toDouble(),
      ltsVoltage: (json['lts_v'] ?? 0.0).toDouble(),
      // Struje
      egtsCurrent: (json['egts_a'] ?? 0.0).toDouble(),
      ectsCurrent: (json['ects_a'] ?? 0.0).toDouble(),
      eotsCurrent: (json['eots_a'] ?? 0.0).toDouble(),
      matsCurrent: (json['mats_a'] ?? 0.0).toDouble(),
      ltsCurrent: (json['lts_a'] ?? 0.0).toDouble(),
    );
  }
}
