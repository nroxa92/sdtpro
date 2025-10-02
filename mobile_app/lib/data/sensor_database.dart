// lib/sensor_database.dart

import 'package:flutter/material.dart';
import 'package:sdt_final/screens/sensor_testing/temperature_sensors_screen.dart';
import 'models/models.dart'; // ISPRAVLJENA PUTANJA

// Prvo definiramo listu senzora temperature kao zasebnu varijablu.
// Ovi objekti će čuvati podatke o mjerenjima.
final List<SensorSubCategory> temperatureSensorsList = [
  SensorSubCategory(name: 'EGTS', targetScreen: Container(), expectedRange: 'temp-ovisno'),
  SensorSubCategory(name: 'ECTS', targetScreen: Container(), expectedRange: 'temp-ovisno'),
  SensorSubCategory(name: 'EOTS', targetScreen: Container(), expectedRange: 'temp-ovisno'),
  SensorSubCategory(name: 'MATS', targetScreen: Container(), expectedRange: 'temp-ovisno'),
  SensorSubCategory(name: 'LTS', targetScreen: Container(), expectedRange: 'temp-ovisno'),
];

// Zatim, definiramo kategorije koje će se prikazivati na glavnom izborniku.
final List<SensorCategory> sensorCategories = [
  SensorCategory(
    name: 'Senzori',
    icon: Icons.sensors,
    subCategories: [
      SensorSubCategory(
        name: 'Senzori Temperature',
        description: 'Testiranje otpora, napona i struje NTC senzora.',
        // KLJUČNI DIO: Ovaj gumb vodi na naš novi ekran i prosljeđuje mu listu senzora
        targetScreen: TemperatureSensorsScreen(sensors: temperatureSensorsList),
      ),
      // Ovdje kasnije možete dodati i druge testove, npr. za senzore tlaka
      // SensorSubCategory(
      //   name: 'Senzori Tlaka',
      //   description: 'Testiranje MAP i ostalih senzora tlaka.',
      //   targetScreen: Container(), // Placeholder za budući ekran
      // ),
    ],
  ),
  SensorCategory(
    name: 'Aktuatori',
    icon: Icons.precision_manufacturing,
    subCategories: [
      // Budući testovi za aktuatore (injektori, bobine...)
    ],
  ),
  // Dodajte ostale glavne kategorije po potrebi
];