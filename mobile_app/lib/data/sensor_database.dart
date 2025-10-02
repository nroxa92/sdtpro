// lib/data/sensor_database.dart
import 'package:flutter/material.dart';
import '../models/models.dart'; // Ispravan import

// Definicija ruta kao konstanti radi izbjegavanja grešaka u pisanju
class AppRoutes {
  static const String temperatureSensors = '/test/temperature_sensors';
  // Ovdje dodajte rute za buduće ekrane
}

// Lista senzora temperature
final List<SensorSubCategory> temperatureSensorsList = [
  SensorSubCategory(name: 'EGTS', routeName: '', expectedRange: 'temp-ovisno'),
  SensorSubCategory(name: 'ECTS', routeName: '', expectedRange: 'temp-ovisno'),
  SensorSubCategory(name: 'EOTS', routeName: '', expectedRange: 'temp-ovisno'),
  SensorSubCategory(name: 'MATS', routeName: '', expectedRange: 'temp-ovisno'),
  SensorSubCategory(name: 'LTS', routeName: '', expectedRange: 'temp-ovisno'),
];

// Glavna lista kategorija za dijagnostiku
final List<SensorCategory> diagnosticCategories = [
  SensorCategory(
    name: 'Senzori',
    icon: Icons.sensors,
    subCategories: [
      SensorSubCategory(
        name: 'Senzori Temperature',
        description: 'Testiranje otpora, napona i struje NTC senzora.',
        routeName: AppRoutes.temperatureSensors, // Koristimo definiranu rutu
      ),
      // Ovdje možete dodati i druge testove
    ],
  ),
  // ... dodajte druge kategorije
];