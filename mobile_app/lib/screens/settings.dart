import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Postavke"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Jezik"),
            subtitle: const Text("Hrvatski / English (uskoro)"),
            onTap: () {
              // Logika za promjenu jezika će doći ovdje
            },
          ),
          ListTile(
            leading: const Icon(Icons.thermostat),
            title: const Text("Mjerne Jedinice"),
            subtitle: const Text("Metričke (zadano)"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

