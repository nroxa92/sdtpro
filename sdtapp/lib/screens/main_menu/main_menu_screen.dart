import 'package:flutter/material.dart';
import '../sensor_testing/temperature_sensors_screen.dart'; // <-- ISPRAVLJENO

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... ostatak koda ostaje isti ...
    // Ovdje je samo import promijenjen
    return Scaffold(
      appBar: AppBar(title: const Text('Glavni Izbornik')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.thermostat),
            title: const Text('Senzori Temperature'),
            subtitle: const Text('Pregled i testiranje senzora'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TemperatureSensorsScreen()),
              );
            },
          )
        ],
      ),
    );
  }
}
