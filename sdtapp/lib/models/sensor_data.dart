import 'package:hive/hive.dart';

part 'sensor_data.g.dart'; // Ova linija će možda biti crvena, ignoriraj za sada

@HiveType(typeId: 1)
class SensorData {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String sensorName;

  @HiveField(2)
  final double temperature;

  @HiveField(3)
  final DateTime timestamp;

  SensorData({
    this.id,
    required this.sensorName,
    required this.temperature,
    required this.timestamp,
  });
}
