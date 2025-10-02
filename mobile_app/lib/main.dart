// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sdt_final/data/sensor_database.dart';
import 'package:sdt_final/screens/can_live_screen.dart';
import 'package:sdt_final/screens/sensor_testing/temperature_sensors_screen.dart';
import 'package:sdt_final/widgets/main_scaffold.dart';

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
        scaffoldBackgroundColor: const Color(0xFF121212), // Tamnija pozadina
        cardColor: Colors.blueGrey[900],
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.tealAccent,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        textTheme: Typography.material2021().white.copyWith(
              titleLarge: const TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white.withOpacity(0.87)),
              bodyLarge: TextStyle(color: Colors.white.withOpacity(0.87)),
              bodyMedium: TextStyle(color: Colors.white.withOpacity(0.60)),
            ),
      ),
      // Početni ekran je MainScaffold, koji sadrži donju navigaciju
      home: const MainScaffold(),
      
      // Definicija svih ruta u aplikaciji za direktnu navigaciju
      routes: {
        AppRoutes.canLiveData: (context) => const CanLiveScreen(),
        AppRoutes.temperatureSensors: (context) => TemperatureSensorsScreen(
              sensors: temperatureSensorItems, // Prosljeđujemo listu senzora
            ),
      },
    );
  }
}