// lib/models/models.dart
import 'package.flutter/material.dart';

// --- VRAĆENE KLASE ZA LIVE DATA ---
// Klasa koja drži podatke koji stižu s CAN busa
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

  // Tvornička metoda za stvaranje objekta iz JSON-a
  factory LiveData.fromJson(Map<String, dynamic> json) {
    return LiveData(
      rpm: (json['rpm'] ?? 0.0).toDouble(),
      throttle: (json['throttle'] ?? 0.0).toDouble(),
      coolantTemp: (json['coolantTemp'] ?? 0.0).toDouble(),
      oilTemp: (json['oilTemp'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? 0.0).toDouble(),
      fuelLevel: (json['fuelLevel'] ?? 0.0).toDouble(),
      mapPressure: (json['mapPressure'] ?? 0.0).toDouble(),
      intakeTemp: (json['intakeTemp'] ?? 0.0).toDouble(),
      exhaustTemp: (json['exhaustTemp'] ?? 0.0).toDouble(),
    );
  }
}


// --- NOVE/AŽURIRANE KLASE ZA IZBORNIK DIJAGNOSTIKE ---

// Glavna kategorija (npr. "Senzori", "Aktuatori")
class SensorCategory {
  final String name;
  final IconData icon;
  final List<SensorSubCategory> subCategories;

  SensorCategory({
    required this.name,
    required this.icon,
    required this.subCategories,
  });
}

// Pod-kategorija (npr. "Senzori Temperature")
class SensorSubCategory {
  final String name;
  final String? description;
  // ISPRAVAK: Više ne držimo widget, već ime rute (putanje) do ekrana.
  // Ovo rješava kružnu ovisnost i ispravna je arhitektura.
  final String routeName; 

  // Polja za praćenje stanja mjerenja
  double? measuredResistance;
  String status;
  final String? expectedRange;

  SensorSubCategory({
    required this.name,
    this.description,
    required this.routeName,
    
    this.measuredResistance,
    this.status = 'pending',
    this.expectedRange,
  });
}