// lib/data/sensor_database.dart
import 'package.flutter/material.dart';
import '../models/models.dart';

// Definicija ruta kao konstanti
class AppRoutes {
  static const String temperatureSensors = '/test/temperature_sensors';
  static const String canLiveData = '/live/can_data';
}

// Lista itema za testiranje senzora temperature
final List<SubCategoryItem> temperatureSensorItems = [
  SubCategoryItem(name: 'EGTS', routeName: ''), // Nema rutu jer je samo item u listi
  SubCategoryItem(name: 'ECTS', routeName: ''),
  SubCategoryItem(name: 'EOTS', routeName: ''),
  SubCategoryItem(name: 'MATS', routeName: ''),
  SubCategoryItem(name: 'LTS', routeName: ''),
];

// Glavna struktura izbornika
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
    name: "Dijagnostika",
    icon: Icons.build,
    subCategories: [
      SubCategoryItem(
        name: 'Senzori Temperature',
        description: 'Testiranje otpora NTC senzora.',
        routeName: AppRoutes.temperatureSensors,
      ),
      // Ovdje dodajte buduće testove...
    ],
  ),
];