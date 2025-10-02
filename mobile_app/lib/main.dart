// lib/models/models.dart
import 'package:flutter/material.dart';

// --- MODEL ZA LIVE CAN PODATKE ---
// Sadrži sva polja definirana u knowledge_base
class LiveData {
  final double rpm;
  final double throttle;
  final double coolantTemp;
  final double oilTemp;
  final double speed;
  final double fuelLevel;
  final double mapPressure;
  final double intakeTemp;
  final double exhaustTemp;

  LiveData({
    this.rpm = 0.0,
    this.throttle = 0.0,
    this.coolantTemp = 0.0,
    this.oilTemp = 0.0,
    this.speed = 0.0,
    this.fuelLevel = 0.0,
    this.mapPressure = 0.0,
    this.intakeTemp = 0.0,
    this.exhaustTemp = 0.0,
  });

  factory LiveData.fromJson(Map<String, dynamic> json) {
    // Ključevi (npr. 'Gas (Throttle)') moraju točno odgovarati
    // onima koje firmware šalje u JSON-u
    return LiveData(
      rpm: (json['RPM'] ?? 0.0).toDouble(),
      throttle: (json['Gas (Throttle)'] ?? 0.0).toDouble(),
      coolantTemp: (json['Temp. rashl. tekućine (ECT)'] ?? 0.0).toDouble(),
      oilTemp: (json['Temp. ulja (EOT)'] ?? 0.0).toDouble(),
      speed: (json['Brzina vozila'] ?? 0.0).toDouble(),
      fuelLevel: (json['Razina goriva'] ?? 0.0).toDouble(),
      mapPressure: (json['Tlak (MAP)'] ?? 0.0).toDouble(),
      intakeTemp: (json['Temp. usisnog zraka (MAT)'] ?? 0.0).toDouble(),
      exhaustTemp: (json['Temp. ispuha (EGT)'] ?? 0.0).toDouble(),
    );
  }
}

// --- MODELI ZA STRUKTURU I NAVIGACIJU IZBORNIKA ---

// Glavna kategorija na početnom ekranu (npr. "Dijagnostika", "Postavke")
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

// Pod-kategorija ili test (npr. "Senzori Temperature", "Test Injektora")
class SubCategoryItem {
  final String name;
  final String? description;
  final String routeName; // Jedinstvena putanja za navigaciju

  // Polja specifična za testove, mogu biti null
  double? measuredValue;
  String status;

  SubCategoryItem({
    required this.name,
    required this.routeName,
    this.description,
    this.measuredValue,
    this.status = 'pending',
  });
}