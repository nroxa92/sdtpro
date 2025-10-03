import 'package:flutter/material.dart';

// --- MODELI ZA STRUKTURU I NAVIGACIJU IZBORNIKA ---

// Glavna kategorija na početnom ekranu (npr. "Senzori", "CAN Greške")
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

  SubCategoryItem({
    required this.name,
    required this.routeName,
    this.description,
  });
}

// --- MODEL ZA LIVE CAN PODATKE ---
// Preuzeto iz tvog koda, služit će za 'can_live_screen.dart'
class LiveData {
  final double rpm;
  final double throttle;
  final double coolantTemp;
  // ... dodaj ostala polja po potrebi

  LiveData({
    this.rpm = 0.0,
    this.throttle = 0.0,
    this.coolantTemp = 0.0,
    // ... inicijaliziraj ostala polja
  });

  factory LiveData.fromJson(Map<String, dynamic> json) {
    return LiveData(
      rpm: (json['RPM'] ?? 0.0).toDouble(),
      throttle: (json['Gas (Throttle)'] ?? 0.0).toDouble(),
      coolantTemp: (json['Temp. rashl. tekućine (ECT)'] ?? 0.0).toDouble(),
      // ... parsiraj ostala polja
    );
  }
}
