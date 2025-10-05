import 'package:flutter/material.dart';
import 'models.dart';
import 'app_routes.dart';

// --- MODEL ZA REFERENTNU TABLICU ---
class ReferenceEntry {
  final int tempC;
  final int nominal;
  final int low;
  final int high;

  ReferenceEntry({
    required this.tempC,
    required this.nominal,
    required this.low,
    required this.high,
  });
}

// --- Referentni podaci otpora ---
final List<ReferenceEntry> detailedResistanceTable = [
  ReferenceEntry(tempC: 30, nominal: 1700, low: 1500, high: 1900),
  ReferenceEntry(tempC: 40, nominal: 1200, low: 1080, high: 1320),
  ReferenceEntry(tempC: 50, nominal: 840, low: 750, high: 930),
  ReferenceEntry(tempC: 60, nominal: 630, low: 510, high: 750),
  ReferenceEntry(tempC: 70, nominal: 440, low: 370, high: 510),
  ReferenceEntry(tempC: 75, nominal: 370, low: 300, high: 440),
  ReferenceEntry(tempC: 80, nominal: 325, low: 280, high: 370),
  ReferenceEntry(tempC: 85, nominal: 285, low: 240, high: 330),
  ReferenceEntry(tempC: 90, nominal: 245, low: 210, high: 280),
  ReferenceEntry(tempC: 100, nominal: 195, low: 160, high: 210),
  ReferenceEntry(tempC: 110, nominal: 145, low: 125, high: 160),
  ReferenceEntry(tempC: 120, nominal: 115, low: 100, high: 125),
];

// Pomoćna funkcija za kreiranje Map-e otpora
Map<int, int> _createResistanceMap(List<ReferenceEntry> entries) {
  return Map.fromEntries(entries.map((e) => MapEntry(e.tempC, e.nominal)));
}

// --- Lista temperature senzora (statični podaci i pinout) ---
// Ovi podaci ostaju za sada, koristit ćemo ih kasnije unutar POD Dashboarda
final List<TemperatureSensorSpec> temperatureSensorItems = [
  TemperatureSensorSpec(
      id: 'EGTS',
      name: 'Ispušni Plinovi (EGTS)',
      ecuPinout: 'B-G4 / F3',
      resistanceTable: _createResistanceMap(detailedResistanceTable)),
  TemperatureSensorSpec(
      id: 'ECTS',
      name: 'Rashladna Tekućina (ECTS)',
      ecuPinout: 'A-A1 / J2',
      resistanceTable: _createResistanceMap(detailedResistanceTable)),
  TemperatureSensorSpec(
      id: 'EOTS',
      name: 'Motorno Ulje (EOTS)',
      ecuPinout: 'A-H4 / J4',
      resistanceTable: _createResistanceMap(detailedResistanceTable)),
  TemperatureSensorSpec(
      id: 'MATS',
      name: 'Usisna Grana (MATS)',
      ecuPinout: 'A-H2 / H3',
      resistanceTable: _createResistanceMap(detailedResistanceTable)),
  TemperatureSensorSpec(
      id: 'LTS',
      name: 'Voda u kojoj vozi (LTS)',
      ecuPinout: 'B-E2 / G2',
      resistanceTable: _createResistanceMap(detailedResistanceTable)),
];

// --- Glavna struktura izbornika (AŽURIRANO) ---
final List<MainMenuCategory> mainMenuCategories = [
  MainMenuCategory(
    name: "CAN Tools",
    icon: Icons.precision_manufacturing,
    subCategories: [
      SubCategoryItem(name: 'CAN Live', routeName: AppRoutes.canLiveData),
      SubCategoryItem(name: 'Greške', routeName: '/can/errors'),
      SubCategoryItem(name: 'Aktuatori', routeName: '/can/actuators'),
    ],
  ),
  // --- IZMIJENJENA KATEGORIJA ---
  MainMenuCategory(
    name: "POD Testovi", // Novo ime
    icon: Icons.memory, // Nova, prikladnija ikona za POD/modul
    subCategories: [
      // Sada imamo samo jednu "podkategoriju" koja vodi na budući dashboard
      SubCategoryItem(
          name: 'Otvori Dashboard',
          routeName: AppRoutes.podDashboard), // Nova ruta
    ],
  ),
];
