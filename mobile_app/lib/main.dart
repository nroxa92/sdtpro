// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sdt_final/data/sensor_database.dart';
import 'package:sdt_final/screens/can_live_screen.dart';
import 'package:sdt_final/screens/main_menu.dart';
import 'package:sdt_final/screens/sensor_testing/temperature_sensors_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDTpro',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey[900],
        scaffoldBackgroundColor: Colors.blueGrey[800],
        cardColor: Colors.blueGrey[700],
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.tealAccent,
          surface: Colors.blueGrey[700]!,
        ),
      ),
      // Početni ekran
      home: const MainMenuScreen(),
      // Definicija svih ruta u aplikaciji
      routes: {
        AppRoutes.canLiveData: (context) => const CanLiveScreen(),
        AppRoutes.temperatureSensors: (context) => TemperatureSensorsScreen(
              sensors: temperatureSensorItems, // Prosljeđujemo listu senzora
            ),
      },
    );
  }
}