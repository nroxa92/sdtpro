// lib/sensor_data.dart
import 'package:flutter/material.dart';
import 'models.dart'; // Mora koristiti klasu TemperatureSensorSpec

// ------------------------------------------------------------------
// Definicija ruta kao konstanti
class AppRoutes {
  static const String temperatureSensors = '/test/temperature_sensors';
  static const String canLiveData = '/live/can_data';
  // Dodajte rute za ostale testove ovdje
  static const String mainScreen = '/';
}

// ------------------------------------------------------------------
// Referentni podaci otpora (Nominal, korak 5C u rasponu 20C-40C)
// Ovo rješava grešku: Undefined name 'referenceResistanceTable'
final Map<int, int> referenceResistanceTable = {
  20: 2500,
  25: 2100,
  30: 1700,
  35: 1450,
  40: 1200,
};

// ------------------------------------------------------------------
// Lista temperature senzora (statični podaci i pinout)
final List<TemperatureSensorSpec> temperatureSensorItems = [
  TemperatureSensorSpec(
    id: 'EGTS',
    name: 'Ispušni Plinovi (EGTS)',
    ecuPinout: 'B-G4 / F3',
    resistanceTable: referenceResistanceTable,
  ),
  TemperatureSensorSpec(
    id: 'ECTS',
    name: 'Rashladna Tekućina (ECTS)',
    ecuPinout: 'A-A1 / J2',
    resistanceTable: referenceResistanceTable,
  ),
  TemperatureSensorSpec(
    id: 'EOTS',
    name: 'Motorno Ulje (EOTS)',
    ecuPinout: 'A-H4 / J4',
    resistanceTable: referenceResistanceTable,
  ),
  TemperatureSensorSpec(
    id: 'MATS',
    name: 'Usisna Grana (MATS)',
    ecuPinout: 'A-H2 / H3',
    resistanceTable: referenceResistanceTable,
  ),
  TemperatureSensorSpec(
    id: 'LTS',
    name: 'Voda u kojoj vozi (LTS)',
    ecuPinout: 'B-E2 / G2',
    resistanceTable: referenceResistanceTable,
  ),
];

// ------------------------------------------------------------------
// Glavna struktura izbornika (MENU)
final List<MainMenuCategory> mainMenuCategories = [
  MainMenuCategory(
    name: "Live Podaci",
    icon: Icons.speed,
    subCategories: [
      SubCategoryItem(
        name: 'CAN Bus Live',
        description: 'Prikaz podataka s CAN sabirnice u stvarnom vremenu.',
        routeName: AppRoutes.canLiveData,
      ),
    ],
  ),
  MainMenuCategory(
    name: "Dijagnostika Senzora",
    icon: Icons.build,
    subCategories: [
      SubCategoryItem(
        name: 'Senzori Temperature (NTC)',
        description: 'Testiranje otpora, napona i struje senzora.',
        routeName: AppRoutes.temperatureSensors,
      ),
    ],
  ),
];
