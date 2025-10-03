import 'package:hive_flutter/hive_flutter.dart';
import '../models/sensor_data.dart'; // <-- ISPRAVLJENO

class HiveDatabase {
  HiveDatabase._privateConstructor();
  static final HiveDatabase instance = HiveDatabase._privateConstructor();

  late Box<SensorData> _sensorDataBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SensorDataAdapter());
    _sensorDataBox = await Hive.openBox<SensorData>('sensor_data');
  }

  Future<void> insertSensorData(SensorData data) async {
    await _sensorDataBox.add(data);
  }

  Future<List<SensorData>> getAllSensorData() async {
    return _sensorDataBox.values.toList();
  }
}
