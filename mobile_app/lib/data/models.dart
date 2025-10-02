// lib/models/models.dart

import 'package:flutter/material.dart';

// Glavna kategorija na početnom ekranu
class SensorCategory {
  final String name;
  final IconData icon;
  // Svaka kategorija sada može imati listu pod-kategorija
  final List<SensorSubCategory> subCategories;

  SensorCategory({
    required this.name,
    required this.icon,
    required this.subCategories,
  });
}

// Pod-kategorija ili individualni test koji se prikazuje nakon odabira glavne kategorije
class SensorSubCategory {
  final String name;
  final String? description;
  // Svaka pod-kategorija vodi na specifičan ekran za testiranje
  final Widget targetScreen;

  // --- POLJA ZA PRAĆENJE STANJA MJERENJA ---
  // Ova polja će se koristiti unutar `TemperatureSensorsScreen`-a
  double? measuredResistance;
  String status;
  final String? expectedRange;

  SensorSubCategory({
    required this.name,
    this.description,
    required this.targetScreen,
    
    // Inicijalne vrijednosti za polja stanja
    this.measuredResistance,
    this.status = 'pending',
    this.expectedRange,
  });
}