import 'package:hive_flutter/hive_flutter.dart';
import 'package:sdtapp/models/sensor_data.dart';

class HiveDatabase {
  // Singleton pattern
  HiveDatabase._privateConstructor();
  static final HiveDatabase instance = HiveDatabase._privateConstructor();

  late Box<SensorData> _sensorDataBox;

  Future<void> init() async {
    // Inicijaliziraj Hive
    await Hive.initFlutter();
    // Registriraj adapter koji smo generirali
    Hive.registerAdapter(SensorDataAdapter());
    // Otvori "kutiju" (box) gdje će se spremati podaci
    _sensorDataBox = await Hive.openBox<SensorData>('sensor_data');
  }

  Future<void> insertSensorData(SensorData data) async {
    await _sensorDataBox.add(data);
  }

  Future<List<SensorData>> getAllSensorData() async {
    return _sensorDataBox.values.toList();
  }
}
