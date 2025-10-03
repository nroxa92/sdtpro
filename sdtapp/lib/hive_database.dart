// lib/hive_database.dart - PRIVREMENO NEUTRALIZIRAN
/*
Ovaj kod je privremeno zakomentiran kako bi se eliminirale greške
uzrokovane neispravnim Hive generiranim datotekama.
*/
// import 'package:hive_flutter/hive_flutter.dart';
// import 'sensor_data.dart'; // Klase SensorData i SensorDataAdapter trenutno ne postoje.

class HiveDatabase {
  // Singleton pattern ostaje
  HiveDatabase._privateConstructor();
  static final HiveDatabase instance = HiveDatabase._privateConstructor();

  // late Box<SensorData> _sensorDataBox; // Uklanjamo reference na Hive Box

  // Sve funkcije vraćaju prazne/mock podatke
  Future<void> init() async {
    // print('Hive Database init temporarily skipped.');
  }

  Future<void> insertSensorData(dynamic data) async {
    // print('Hive insert temporarily skipped.');
  }

  // Funkcija vraća praznu listu kako bi UI mogao raditi bez Hive-a
  Future<List<dynamic>> getAllSensorData() async {
    return [];
  }
}
